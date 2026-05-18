from __future__ import annotations

import argparse
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

from input_forward import __version__
from input_forward.devices import list_input_devices, select_devices_interactively

DEFAULT_REMOTE_HOST = 'copernicus'
DEFAULT_REMOTE_COMMAND = 'input-forward server'
REPO_ROOT = Path(__file__).resolve().parent.parent
SSH_CONFIG_PATH = Path.home() / '.ssh' / 'config'
SSH_KNOWN_HOSTS_PATH = Path.home() / '.ssh' / 'known_hosts'


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog='input-forward')
    parser.add_argument('--version', action='version', version=f'%(prog)s {__version__}')
    subparsers = parser.add_subparsers(dest='command', required=True)

    list_parser = subparsers.add_parser('list-devices', help='list local input devices')
    list_parser.set_defaults(func=cmd_list_devices)

    select_parser = subparsers.add_parser('select-devices', help='interactively select local devices using fzy')
    select_parser.set_defaults(func=cmd_select_devices)

    client_parser = subparsers.add_parser('client', help='capture and forward local events on stdout')
    add_device_arguments(client_parser, select_default=False)
    client_parser.set_defaults(func=cmd_client)

    server_parser = subparsers.add_parser('server', help='replay forwarded events from stdin via uinput')
    server_parser.set_defaults(func=cmd_server)

    run_parser = subparsers.add_parser('run', help='run local client and remote server over ssh')
    add_device_arguments(run_parser, select_default=False)
    add_run_arguments(run_parser, include_remote_host=True)
    run_parser.set_defaults(func=cmd_run)

    connect_parser = subparsers.add_parser(
        'connect',
        help='interactive happy-path: pick a remote host and local devices, then start forwarding',
    )
    connect_parser.add_argument('remote_host', nargs='?', help='remote SSH host; if omitted, choose interactively')
    add_device_arguments(connect_parser, select_default=True)
    add_run_arguments(connect_parser, include_remote_host=False)
    connect_parser.set_defaults(func=cmd_connect)

    return parser


def add_device_arguments(parser: argparse.ArgumentParser, *, select_default: bool) -> None:
    parser.add_argument('--keyboard', action='append', default=[])
    parser.add_argument('--mouse', action='append', default=[])
    if select_default:
        parser.add_argument(
            '--no-select',
            dest='select',
            action='store_false',
            default=True,
            help='skip interactive local device selection unless no devices were given',
        )
        parser.add_argument('--select', dest='select', action='store_true', help=argparse.SUPPRESS)
    else:
        parser.add_argument('--select', action='store_true', help='choose devices interactively with fzy')
    parser.add_argument('--no-grab', action='store_true')


def add_run_arguments(parser: argparse.ArgumentParser, *, include_remote_host: bool) -> None:
    if include_remote_host:
        parser.add_argument('--remote-host', default=DEFAULT_REMOTE_HOST)
    parser.add_argument(
        '--remote-command',
        help='full remote shell command to start the server; defaults to "input-forward server"',
    )
    parser.add_argument('--local-sudo', dest='local_sudo', action='store_true', default=True)
    parser.add_argument('--no-local-sudo', dest='local_sudo', action='store_false')
    parser.add_argument('--remote-sudo', dest='remote_sudo', action='store_true', default=False)


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return int(args.func(args))


def cmd_list_devices(_args: argparse.Namespace) -> int:
    for device in list_input_devices():
        print(device.summary)
    return 0


def cmd_select_devices(_args: argparse.Namespace) -> int:
    keyboard, pointers = select_devices_interactively()
    print(f'keyboard={keyboard}')
    for pointer in pointers:
        print(f'mouse={pointer}')
    return 0


def cmd_client(args: argparse.Namespace) -> int:
    keyboard_paths, mouse_paths = resolve_device_selection(args.keyboard, args.mouse, args.select)
    from input_forward import client

    argv = []
    for path in keyboard_paths:
        argv.extend(['--keyboard', path])
    for path in mouse_paths:
        argv.extend(['--mouse', path])
    if args.no_grab:
        argv.append('--no-grab')
    return client.main(argv)


def cmd_server(_args: argparse.Namespace) -> int:
    from input_forward import server

    return server.main([])


def cmd_run(args: argparse.Namespace) -> int:
    keyboard_paths, mouse_paths = resolve_device_selection(args.keyboard, args.mouse, args.select)
    remote_cmd = build_remote_command(
        remote_command=args.remote_command or DEFAULT_REMOTE_COMMAND,
        remote_sudo=args.remote_sudo,
    )
    return run_session(
        keyboard_paths=keyboard_paths,
        mouse_paths=mouse_paths,
        no_grab=args.no_grab,
        local_sudo=args.local_sudo,
        remote_host=args.remote_host,
        remote_cmd=remote_cmd,
    )


def cmd_connect(args: argparse.Namespace) -> int:
    remote_host = args.remote_host or choose_remote_host_interactively()
    keyboard_paths, mouse_paths = resolve_device_selection(args.keyboard, args.mouse, args.select)

    remote_command = args.remote_command

    if remote_command is None:
        if remote_has_installed_input_forward(remote_host):
            remote_command = DEFAULT_REMOTE_COMMAND
            print(f'info: using installed input-forward on {remote_host}', file=sys.stderr)
        else:
            raise SystemExit(
                f'error: input-forward is not installed on {remote_host}; '
                'install it there or pass --remote-command'
            )

    remote_cmd = build_remote_command(
        remote_command=remote_command,
        remote_sudo=args.remote_sudo,
    )
    return run_session(
        keyboard_paths=keyboard_paths,
        mouse_paths=mouse_paths,
        no_grab=args.no_grab,
        local_sudo=args.local_sudo,
        remote_host=remote_host,
        remote_cmd=remote_cmd,
    )


def run_session(
    *,
    keyboard_paths: list[str],
    mouse_paths: list[str],
    no_grab: bool,
    local_sudo: bool,
    remote_host: str,
    remote_cmd: str,
) -> int:
    client_cmd = [*local_cli_invocation(), 'client']
    for path in keyboard_paths:
        client_cmd.extend(['--keyboard', path])
    for path in mouse_paths:
        client_cmd.extend(['--mouse', path])
    if no_grab:
        client_cmd.append('--no-grab')
    if local_sudo:
        client_cmd.insert(0, 'sudo')

    ssh_cmd = ['ssh', '-T', remote_host, remote_cmd]

    ssh_proc = subprocess.Popen(ssh_cmd, stdin=subprocess.PIPE, cwd=str(REPO_ROOT))
    assert ssh_proc.stdin is not None
    try:
        client_proc = subprocess.Popen(client_cmd, stdout=ssh_proc.stdin, cwd=str(REPO_ROOT))
    finally:
        ssh_proc.stdin.close()

    client_rc = client_proc.wait()
    ssh_rc = ssh_proc.wait()
    return client_rc if client_rc != 0 else ssh_rc


def local_cli_invocation() -> list[str]:
    installed = shutil.which('input-forward')
    if installed is not None:
        return [installed]
    return [sys.executable, '-m', 'input_forward']


def resolve_device_selection(keyboards: list[str], mice: list[str], select: bool) -> tuple[list[str], list[str]]:
    keyboard_paths = list(keyboards)
    mouse_paths = list(mice)

    if select or (not keyboard_paths and not mouse_paths):
        selected_keyboard, selected_mice = select_devices_interactively()
        if not keyboard_paths:
            keyboard_paths = [selected_keyboard]
        if not mouse_paths:
            mouse_paths = selected_mice

    if not keyboard_paths and not mouse_paths:
        raise SystemExit('error: at least one --keyboard or --mouse device is required')
    return keyboard_paths, mouse_paths


def choose_remote_host_interactively() -> str:
    hosts = discover_ssh_hosts()
    if shutil.which('fzy') is not None and hosts:
        try:
            return select_string_with_fzy(hosts, prompt='remote> ')
        except RuntimeError as exc:
            raise SystemExit(str(exc)) from exc
    return prompt_with_default('remote host', DEFAULT_REMOTE_HOST)


def discover_ssh_hosts() -> list[str]:
    candidates: list[str] = [DEFAULT_REMOTE_HOST]

    if SSH_CONFIG_PATH.exists():
        try:
            for raw in SSH_CONFIG_PATH.read_text(encoding='utf-8').splitlines():
                line = raw.strip()
                if not line or line.startswith('#'):
                    continue
                lowered = line.lower()
                if not lowered.startswith('host '):
                    continue
                for host in line.split()[1:]:
                    if any(token in host for token in ('*', '?', '!')):
                        continue
                    candidates.append(host)
        except OSError:
            pass

    if SSH_KNOWN_HOSTS_PATH.exists():
        try:
            for raw in SSH_KNOWN_HOSTS_PATH.read_text(encoding='utf-8').splitlines():
                if not raw or raw.startswith('|'):
                    continue
                host_field = raw.split()[0]
                for host in host_field.split(','):
                    if host.startswith('[') and ']:' in host:
                        host = host[1:].split(']:', 1)[0]
                    if any(token in host for token in ('*', '?')):
                        continue
                    if host:
                        candidates.append(host)
        except OSError:
            pass

    deduped: list[str] = []
    seen: set[str] = set()
    for host in candidates:
        if host in seen:
            continue
        seen.add(host)
        deduped.append(host)
    return deduped


def select_string_with_fzy(options: list[str], *, prompt: str) -> str:
    if not options:
        raise RuntimeError('no selectable options')

    result = subprocess.run(
        ['fzy', '-p', prompt],
        input='\n'.join(options) + '\n',
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError('selection cancelled')

    selected = result.stdout.strip()
    if not selected:
        raise RuntimeError('selection cancelled')
    return selected


def prompt_with_default(label: str, default: str) -> str:
    response = input(f'{label} [{default}]: ').strip()
    return response or default


def remote_has_installed_input_forward(remote_host: str) -> bool:
    result = subprocess.run(
        [
            'ssh',
            '-o',
            'BatchMode=yes',
            '-o',
            'ConnectTimeout=5',
            remote_host,
            'bash -lc "command -v input-forward >/dev/null"',
        ],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return result.returncode == 0


def build_remote_command(
    *,
    remote_command: str,
    remote_sudo: bool,
) -> str:
    server_exec = remote_command

    if remote_sudo:
        server_exec = f'sudo {server_exec}'

    return f'bash -lc {shlex.quote(server_exec)}'
