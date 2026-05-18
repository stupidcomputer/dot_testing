from __future__ import annotations

import os
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

INPUT_DIR = Path("/dev/input")
BY_ID_DIR = INPUT_DIR / "by-id"
BY_PATH_DIR = INPUT_DIR / "by-path"
SYS_INPUT_DIR = Path("/sys/class/input")


@dataclass(frozen=True)
class DeviceInfo:
    event_path: str
    display_path: str
    name: str
    aliases: tuple[str, ...]
    guessed_role: str

    @property
    def summary(self) -> str:
        aliases = ", ".join(self.aliases)
        if aliases:
            return f"[{self.guessed_role}] {self.display_path} :: {self.name} ({aliases})"
        return f"[{self.guessed_role}] {self.display_path} :: {self.name}"


def list_input_devices() -> list[DeviceInfo]:
    alias_map = _build_alias_map()
    devices: list[DeviceInfo] = []
    for event_node in sorted(INPUT_DIR.glob("event*"), key=lambda p: _numeric_suffix(p.name)):
        event_path = str(event_node.resolve())
        aliases = tuple(alias_map.get(event_path, ()))
        name = _device_name_for_event(event_node.name)
        display_path = _preferred_display_path(event_path, aliases)
        guessed_role = _guess_role(display_path, aliases, name)
        devices.append(
            DeviceInfo(
                event_path=event_path,
                display_path=display_path,
                name=name,
                aliases=aliases,
                guessed_role=guessed_role,
            )
        )
    return devices


def keyboard_devices(devices: Iterable[DeviceInfo]) -> list[DeviceInfo]:
    return [device for device in devices if device.guessed_role == "keyboard"]


def pointer_devices(devices: Iterable[DeviceInfo]) -> list[DeviceInfo]:
    return [device for device in devices if device.guessed_role != "keyboard"]


def select_devices_interactively() -> tuple[str, list[str]]:
    devices = list_input_devices()
    keyboards = keyboard_devices(devices)
    pointers = pointer_devices(devices)

    if not keyboards:
        raise RuntimeError("no keyboard-like devices found")

    keyboard = _select_one_with_fzy(keyboards, prompt="keyboard> ")
    selected_pointers: list[str] = []
    remaining = [device for device in pointers if device.event_path != keyboard.event_path]

    while remaining:
        sentinel = DeviceInfo(
            event_path="",
            display_path="[done]",
            name="Finish mouse/touchpad selection",
            aliases=(),
            guessed_role="sentinel",
        )
        choice = _select_one_with_fzy([sentinel, *remaining], prompt="pointer> ")
        if choice.event_path == "":
            break
        selected_pointers.append(choice.display_path)
        remaining = [device for device in remaining if device.event_path != choice.event_path]

    return keyboard.display_path, selected_pointers


def _build_alias_map() -> dict[str, list[str]]:
    alias_map: dict[str, list[str]] = {}
    for base in (BY_ID_DIR, BY_PATH_DIR):
        if not base.exists():
            continue
        for entry in sorted(base.iterdir()):
            if not entry.is_symlink():
                continue
            try:
                target = str(entry.resolve())
            except OSError:
                continue
            alias_map.setdefault(target, []).append(str(entry))
    return alias_map


def _device_name_for_event(event_name: str) -> str:
    name_path = SYS_INPUT_DIR / event_name / "device" / "name"
    try:
        return name_path.read_text(encoding="utf-8").strip()
    except OSError:
        return event_name


def _preferred_display_path(event_path: str, aliases: tuple[str, ...]) -> str:
    preferred_suffixes = ("-event-kbd", "-event-mouse")
    for alias in aliases:
        if alias.endswith(preferred_suffixes):
            return alias
    if aliases:
        return aliases[0]
    return event_path


def _guess_role(display_path: str, aliases: tuple[str, ...], name: str) -> str:
    candidates = (display_path, *aliases)
    if any(candidate.endswith("-event-kbd") for candidate in candidates):
        return "keyboard"
    if any(candidate.endswith("-event-mouse") for candidate in candidates):
        return "pointer"

    lower_name = name.lower()
    if any(token in lower_name for token in ("keyboard", "kbd")):
        return "keyboard"
    if any(token in lower_name for token in ("mouse", "touchpad", "trackpoint", "pointing")):
        return "pointer"
    return "other"


def _select_one_with_fzy(devices: list[DeviceInfo], *, prompt: str) -> DeviceInfo:
    if not devices:
        raise RuntimeError("no selectable devices")
    if shutil.which("fzy") is None:
        raise RuntimeError("interactive selection requires `fzy` in PATH")

    summary_map: dict[str, DeviceInfo] = {}
    rows: list[str] = []
    for index, device in enumerate(devices, start=1):
        row = f"{index:02d} {device.summary}"
        summary_map[row] = device
        rows.append(row)

    import subprocess

    result = subprocess.run(
        ["fzy", "-p", prompt],
        input="\n".join(rows) + "\n",
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("device selection cancelled")

    selected = result.stdout.strip()
    if selected not in summary_map:
        raise RuntimeError("fzy returned an unknown selection")
    return summary_map[selected]


def _numeric_suffix(name: str) -> int:
    digits = "".join(ch for ch in name if ch.isdigit())
    return int(digits or 0)
