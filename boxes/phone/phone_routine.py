#!/data/data/com.termux/files/usr/bin/python3
# NOTE: not `#!/usr/bin/env python3` -- /usr/bin/env does not exist on
# Android's real filesystem. It only appears to work from an interactive
# Termux shell because termux-exec rewrites such paths via LD_PRELOAD, which
# your login shell sets up. Anything that execs this script *without* going
# through a Termux shell -- notably termux-notification button actions,
# which the Termux:API app invokes directly -- won't have that shim active,
# so the shebang must be Termux's real absolute python3 path.
"""phone-routine: wake-up alarm + timed procedure runner for Termux.

Single-file, stdlib-only. See `phone-routine doctor` for a pre-flight check
of the termux-api binaries and data files this depends on.
"""

import argparse
import copy
import curses
import hashlib
import json
import math
import os
import shutil
import subprocess
import sys
import tempfile
import time
import wave
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

# --------------------------------------------------------------------------
# Paths
# --------------------------------------------------------------------------

HOME = Path.home()
ORG_DATA_DIR = HOME / "org" / "generated_data"
PROCEDURES_FILE = ORG_DATA_DIR / "procedures.json"

CONFIG_FILE = HOME / ".config" / "phone-routine" / "config.json"

CACHE_DIR = HOME / ".cache" / "phone-routine"
CONTROL_DIR = CACHE_DIR / "control"
LOCK_FILE = CONTROL_DIR / "lock"
CURRENT_RUN_FILE = CONTROL_DIR / "current_run.json"
SIGNAL_FILE = CONTROL_DIR / "signal.json"
STATE_FILE = CONTROL_DIR / "state.json"
TONE_FILE = CACHE_DIR / "tone.wav"
TONE_META_FILE = CACHE_DIR / "tone.wav.meta.json"
LOG_FILE = CACHE_DIR / "logs" / "phone-routine.log"

DAEMON_LOCK_FILE = CONTROL_DIR / "daemon_lock"
HEARTBEAT_FILE = CACHE_DIR / "daemon_heartbeat.json"
FIRED_MARKER_FILE = CACHE_DIR / "last_fired.json"

ALARM_NOTIF_ID = "phone-routine-alarm"
GRACE_NOTIF_ID = "phone-routine-grace"
PROCEDURE_NOTIF_ID = "phone-routine-procedure"

ADVANCE_ACTIONS = {"ack", "skip", "skip-grace"}
ABORT_ACTIONS = {"abort", "quit"}

DEFAULT_CONFIG = {
    "grace_period_seconds": 60,
    "morning_routine_name_substring": "Morning",
    "job_id": 4200,
    "tick_seconds": 0.2,
    "notify_interval_seconds": 5,
    # termux-job-scheduler has no one-shot "run after N ms" primitive --
    # --period-ms has a hard floor of 900000ms (15min) on Android N+. It is
    # used only as a backstop that revives the daemon below if killed; the
    # daemon itself is what actually sleeps until wake time.
    "backstop_period_ms": 900000,
    "daemon_tick_seconds": 30,
    "daemon_stale_seconds": 180,
    "tone": {
        "frequency_hz": 1000,
        "beep_seconds": 0.3,
        "gap_seconds": 0.15,
        "repeats": 3,
        "volume": 0.6,
    },
}


class DataError(RuntimeError):
    pass


class LockError(RuntimeError):
    pass


def resolve_self_path():
    # Notification button actions and RUN_COMMAND-launched sessions are
    # invoked outside this process's own shell environment, where PATH may
    # not include ~/.local/bin (it's typically added by .bashrc, which a
    # non-interactive invocation won't source) -- resolve an absolute path
    # once so those commands don't depend on PATH at all.
    return shutil.which("phone-routine") or str(Path(__file__).resolve())


# --------------------------------------------------------------------------
# Logging
# --------------------------------------------------------------------------

def log(msg):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    try:
        LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(LOG_FILE, "a") as f:
            f.write(line + "\n")
    except OSError:
        pass
    if sys.stderr.isatty():
        print(line, file=sys.stderr)


# --------------------------------------------------------------------------
# Config
# --------------------------------------------------------------------------

def load_config():
    cfg = copy.deepcopy(DEFAULT_CONFIG)
    if CONFIG_FILE.exists():
        try:
            user_cfg = json.loads(CONFIG_FILE.read_text())
        except json.JSONDecodeError as e:
            log(f"config file invalid JSON, using defaults: {e}")
            user_cfg = {}
        for k, v in user_cfg.items():
            if isinstance(v, dict) and isinstance(cfg.get(k), dict):
                cfg[k].update(v)
            else:
                cfg[k] = v
    return cfg


# --------------------------------------------------------------------------
# Data loading (tomorrow*.json, procedures.json)
# --------------------------------------------------------------------------

@dataclass
class Segment:
    index: int
    text: str
    speech_text: str
    duration_seconds: int


@dataclass
class Procedure:
    id: str
    name: str
    segments: list = field(default_factory=list)


def find_tomorrow_file(org_dir=None):
    org_dir = org_dir or ORG_DATA_DIR
    matches = sorted(org_dir.glob("tomorrow*.json"))
    if len(matches) != 1:
        raise DataError(
            f"expected exactly one tomorrow*.json in {org_dir}, found "
            f"{len(matches)}: {matches}"
        )
    return matches[0]


def load_wakeup_time(org_dir=None):
    path = find_tomorrow_file(org_dir)
    try:
        raw = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        raise DataError(f"{path}: invalid JSON: {e}")
    matches = [
        e for e in raw
        if str(e.get("name", "")).strip().casefold() == "wakeup time"
    ]
    if len(matches) != 1:
        raise DataError(
            f"expected exactly one 'Wakeup time' entry in {path}, found "
            f"{len(matches)}"
        )
    scheduled = matches[0]["scheduled"]
    try:
        return datetime.strptime(scheduled, "%Y-%m-%d %H:%M")
    except ValueError as e:
        raise DataError(f"{path}: unparseable 'scheduled' value {scheduled!r}: {e}")


def load_procedures(path=None):
    path = path or PROCEDURES_FILE
    if not path.exists():
        raise DataError(f"procedures file not found: {path}")
    try:
        raw = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        raise DataError(f"{path}: invalid JSON: {e}")
    procedures = []
    for p in raw:
        segs = []
        for i, item in enumerate(p.get("items", [])):
            segs.append(Segment(
                index=i,
                text=item["text"],
                speech_text=item.get("actually_read_this", item["text"]),
                duration_seconds=int(item["duration_seconds"]),
            ))
        if not segs:
            continue
        procedures.append(Procedure(id=str(p["id"]), name=p["name"], segments=segs))
    return procedures


def find_procedure_by_id(procedures, pid):
    for p in procedures:
        if p.id == str(pid):
            return p
    raise DataError(f"no procedure with id {pid!r}")


def find_morning_routine(procedures, substring):
    sub = substring.casefold()
    for p in procedures:
        if sub in p.name.casefold():
            return p
    raise DataError(f"no procedure found with name containing {substring!r}")


# --------------------------------------------------------------------------
# Termux CLI wrappers (unverified on-device — see phone-routine doctor)
# --------------------------------------------------------------------------

def _run_termux(args, timeout=15):
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
        if result.returncode != 0:
            log(f"{' '.join(args)} failed (rc={result.returncode}): {result.stderr.strip()}")
        return result
    except FileNotFoundError:
        log(f"binary not found: {args[0]}")
        return None
    except subprocess.TimeoutExpired:
        log(f"{' '.join(args)} timed out")
        return None


def termux_notify(notif_id, title, content, ongoing=False, button1=None, button1_action=None, priority="high"):
    # Community usage of termux-notification consistently sets --priority
    # explicitly (e.g. `--priority max`) for notifications carrying action
    # buttons -- default priority appears to not reliably render buttons
    # on all Android versions/OEMs. Default to "high" here since every
    # button-bearing notification in this program needs to be tappable.
    args = ["termux-notification", "--id", str(notif_id), "--title", title, "--content", content]
    if ongoing:
        args.append("--ongoing")
    if priority:
        args += ["--priority", priority]
    if button1:
        args += ["--button1", button1]
    if button1_action:
        args += ["--button1-action", button1_action]
    _run_termux(args)


def termux_notify_remove(notif_id):
    # Unlike termux-notification, the id here is positional, not --id.
    _run_termux(["termux-notification-remove", str(notif_id)])


# One persistent background espeak process per script invocation, fed over
# its stdin pipe (espeak reads and speaks stdin line-by-line when given no
# text argument) -- avoids paying process-startup cost for every single
# announcement, which matters when halfway/10s/3-2-1 cues land within a
# couple seconds of each other. Respawned transparently if it dies.
_espeak_proc = None


def _get_espeak_proc():
    global _espeak_proc
    if _espeak_proc is not None and _espeak_proc.poll() is None:
        return _espeak_proc
    try:
        _espeak_proc = subprocess.Popen(
            ["espeak"], stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        _espeak_proc = None
    return _espeak_proc


def speak_text(text):
    global _espeak_proc
    proc = _get_espeak_proc()
    if proc is None:
        log(f"espeak not found, would have said: {text!r}")
        return
    try:
        proc.stdin.write((text + "\n").encode("utf-8", errors="replace"))
        proc.stdin.flush()
    except (BrokenPipeError, OSError) as e:
        log(f"espeak pipe write failed ({e!r}); will respawn on next call")
        _espeak_proc = None


def termux_media_play(path):
    _run_termux(["termux-media-player", "play", str(path)])


def termux_media_stop():
    _run_termux(["termux-media-player", "stop"])


def termux_wake_lock():
    _run_termux(["termux-wake-lock"])


def termux_wake_unlock():
    _run_termux(["termux-wake-unlock"])


def termux_job_cancel(job_id):
    _run_termux(["termux-job-scheduler", "--cancel", "--job-id", str(job_id)])


def termux_job_schedule_periodic(job_id, script_path, period_ms):
    # termux-job-scheduler has no one-shot delayed-run primitive (confirmed
    # against the real termux-api-package source — flags are --job-id,
    # --script, --period-ms [floor 900000ms/15min on Android N+], --network,
    # --battery-not-low, --storage-not-low, --charging, --persisted,
    # --trigger-content-uri/--trigger-content-flag, --cancel/--cancel-all).
    # Used here only as a periodic backstop that revives wakeup-daemon if
    # it gets killed; real wake-time precision comes from the daemon's own
    # sleep-until-wake-time loop. Even periodic jobs are only a *lower
    # bound* under Doze -- disable battery optimization for Termux +
    # Termux:API on-device for this to be reasonably prompt.
    _run_termux([
        "termux-job-scheduler",
        "--job-id", str(job_id),
        "--script", str(script_path),
        "--period-ms", str(int(period_ms)),
        "--persisted", "true",
    ])


def launch_visible_session(binary_path, args):
    # Opens a NEW, visible Termux session running `binary_path args...`
    # (the same mechanism Termux:Widget uses). Requires
    # `allow-external-apps = true` in termux.properties and the
    # com.termux.permission.RUN_COMMAND permission granted at least once.
    # Subject to Android 10+ background-activity-start restrictions —
    # best-effort only, may silently fail depending on device/OEM; the
    # notification + manual `phone-routine attach` remain the fallback.
    cmd = [
        "am", "startservice",
        "--user", "0",
        "-n", "com.termux/com.termux.app.RunCommandService",
        "-a", "com.termux.RUN_COMMAND",
        "--es", "com.termux.RUN_COMMAND_PATH", str(binary_path),
        "--ez", "com.termux.RUN_COMMAND_BACKGROUND", "false",
    ]
    if args:
        cmd += ["--esa", "com.termux.RUN_COMMAND_ARGUMENTS", ",".join(args)]
    _run_termux(cmd)


# --------------------------------------------------------------------------
# Tone synthesis
# --------------------------------------------------------------------------

def synthesize_tone(path, tone_cfg):
    framerate = 44100
    amplitude = int(32767 * tone_cfg.get("volume", 0.6))
    freq = tone_cfg.get("frequency_hz", 1000)
    beep_seconds = tone_cfg.get("beep_seconds", 0.3)
    gap_seconds = tone_cfg.get("gap_seconds", 0.15)
    repeats = tone_cfg.get("repeats", 3)

    samples = bytearray()

    def beep():
        n = int(framerate * beep_seconds)
        fade = max(int(framerate * 0.005), 1)  # 5ms fade to avoid clicks
        for i in range(n):
            env = 1.0
            if i < fade:
                env = i / fade
            elif i > n - fade:
                env = (n - i) / fade
            val = int(amplitude * env * math.sin(2 * math.pi * freq * (i / framerate)))
            samples.extend(int(val).to_bytes(2, "little", signed=True))

    def silence(seconds):
        samples.extend(b"\x00\x00" * int(framerate * seconds))

    for _ in range(max(repeats, 1)):
        beep()
        silence(gap_seconds)

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(framerate)
        wf.writeframes(bytes(samples))

    return len(samples) / 2 / framerate


def ensure_tone_cached(config):
    tone_cfg = config.get("tone", DEFAULT_CONFIG["tone"])
    digest = hashlib.sha256(json.dumps(tone_cfg, sort_keys=True).encode()).hexdigest()
    meta = {}
    if TONE_META_FILE.exists():
        try:
            meta = json.loads(TONE_META_FILE.read_text())
        except (json.JSONDecodeError, OSError):
            meta = {}
    if not TONE_FILE.exists() or meta.get("hash") != digest:
        duration = synthesize_tone(TONE_FILE, tone_cfg)
        TONE_META_FILE.write_text(json.dumps({"hash": digest, "duration_seconds": duration}))
    else:
        duration = meta.get("duration_seconds", 1.0)
    return duration


# --------------------------------------------------------------------------
# IPC / control state
# --------------------------------------------------------------------------

def _atomic_write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=str(path.parent))
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(data, f)
        os.replace(tmp, path)
    except Exception:
        try:
            os.unlink(tmp)
        except FileNotFoundError:
            pass
        raise


def _steal_stale_lock():
    try:
        existing = json.loads(LOCK_FILE.read_text())
        pid = existing.get("pid")
        os.kill(pid, 0)
        return False  # process is alive, lock is not stale
    except ProcessLookupError:
        log("stealing stale phone-routine lock (owning process is dead)")
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        log("phone-routine lock file unreadable/corrupt, stealing")
    try:
        LOCK_FILE.unlink()
    except FileNotFoundError:
        pass
    return True


def acquire_lock(kind):
    CONTROL_DIR.mkdir(parents=True, exist_ok=True)
    for _ in range(2):
        try:
            fd = os.open(str(LOCK_FILE), os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o644)
        except FileExistsError:
            if _steal_stale_lock():
                continue
            raise LockError("another phone-routine run is already active")
        run_id = f"{os.getpid()}-{int(time.time())}"
        with os.fdopen(fd, "w") as f:
            json.dump({"pid": os.getpid(), "run_id": run_id, "kind": kind, "started_at": time.time()}, f)
        write_current_run(run_id, kind)
        return run_id
    raise LockError("failed to acquire phone-routine run lock")


def release_lock():
    for p in (LOCK_FILE, CURRENT_RUN_FILE):
        try:
            p.unlink()
        except FileNotFoundError:
            pass


def write_current_run(run_id, kind):
    _atomic_write_json(CURRENT_RUN_FILE, {"run_id": run_id, "kind": kind, "started_at": time.time()})


def read_current_run():
    try:
        return json.loads(CURRENT_RUN_FILE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def write_signal(action):
    current = read_current_run()
    run_id = current["run_id"] if current else None
    _atomic_write_json(SIGNAL_FILE, {"action": action, "run_id": run_id, "ts": time.time()})


def consume_signal(run_id):
    try:
        data = json.loads(SIGNAL_FILE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return None
    try:
        SIGNAL_FILE.unlink()
    except FileNotFoundError:
        pass
    if data.get("run_id") != run_id:
        return None
    return data.get("action")


def write_state(snapshot):
    _atomic_write_json(STATE_FILE, snapshot)


def read_state():
    try:
        return json.loads(STATE_FILE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return None


# --------------------------------------------------------------------------
# Segment-timing engine
# --------------------------------------------------------------------------

def build_segment_events(seg, next_seg):
    """List of (offset_seconds_from_segment_start, kind, speech_text)."""
    d = seg.duration_seconds
    events = [(0.0, "start", seg.speech_text)]
    if next_seg is not None:
        events.append((d / 2, "halfway", f"Halfway. {next_seg.speech_text}"))
        if d >= 10:
            events.append((max(d - 10, 0), "warn10", "Ten"))
        if d >= 3:
            events.append((max(d - 3, 0), "count3", "Three"))
            events.append((max(d - 2, 0), "count2", "Two"))
            events.append((max(d - 1, 0), "count1", "One"))
    events.sort(key=lambda e: e[0])
    return events


def _segment_snapshot(procedure, run_id, current_index, elapsed, mode="running_procedure"):
    segs = []
    for i, s in enumerate(procedure.segments):
        if i < current_index:
            status = "done"
        elif i == current_index:
            status = "current"
        else:
            status = "upcoming"
        segs.append({"index": i, "text": s.text, "duration_seconds": s.duration_seconds, "status": status})
    if current_index < len(procedure.segments):
        remaining = max(procedure.segments[current_index].duration_seconds - elapsed, 0)
    else:
        remaining = 0
    return {
        "run_id": run_id,
        "mode": mode,
        "procedure_id": procedure.id,
        "procedure_name": procedure.name,
        "segments": segs,
        "current_index": current_index,
        "elapsed_seconds": elapsed,
        "remaining_seconds": remaining,
        "updated_at": time.time(),
    }


def _banner_snapshot(run_id, mode, title, detail, remaining_seconds=0):
    """State snapshot for non-procedure modes (alarm ringing / grace period /
    idle-with-a-message) -- rendered as a centered banner by the TUI instead
    of a segment list, see BANNER_LABELS / _render_banner."""
    return {
        "run_id": run_id,
        "mode": mode,
        "procedure_id": None,
        "procedure_name": title,
        "detail": detail,
        "segments": [],
        "current_index": 0,
        "elapsed_seconds": 0,
        "remaining_seconds": remaining_seconds,
        "updated_at": time.time(),
    }


def run_procedure_segments(procedure, run_id, config, tick_hook=None):
    """Drives `procedure` to completion, honoring skip/abort signals.

    tick_hook(snapshot), if given, is called once per loop iteration (e.g.
    to render curses + read a keypress); it's responsible for its own
    pacing (curses stdscr.timeout()). Without it, this sleeps tick_seconds
    itself.
    """
    tick = config.get("tick_seconds", 0.2)
    notify_interval = config.get("notify_interval_seconds", 5)
    n = len(procedure.segments)

    for idx, seg in enumerate(procedure.segments):
        next_seg = procedure.segments[idx + 1] if idx + 1 < n else None
        events = build_segment_events(seg, next_seg)
        fired = set()
        speak_text(seg.speech_text)
        seg_start = time.monotonic()
        last_notify = 0.0

        while True:
            elapsed = time.monotonic() - seg_start

            action = consume_signal(run_id)
            if action in ABORT_ACTIONS:
                termux_notify_remove(PROCEDURE_NOTIF_ID)
                write_state(_segment_snapshot(procedure, run_id, idx, elapsed, mode="idle"))
                return "aborted"
            if action in ADVANCE_ACTIONS:
                break

            for offset, kind, text in events:
                if kind == "start" or offset in fired:
                    continue
                if elapsed >= offset:
                    fired.add(offset)
                    speak_text(text)

            snapshot = _segment_snapshot(procedure, run_id, idx, elapsed)
            write_state(snapshot)

            now = time.monotonic()
            if now - last_notify >= notify_interval:
                remaining = max(seg.duration_seconds - elapsed, 0)
                termux_notify(
                    PROCEDURE_NOTIF_ID, seg.text, f"{int(remaining)}s remaining",
                    ongoing=True, button1="Skip", button1_action=f"{resolve_self_path()} signal skip",
                )
                last_notify = now

            if elapsed >= seg.duration_seconds:
                break

            if tick_hook:
                tick_hook(snapshot)
            else:
                time.sleep(tick)

    speak_text("Procedure complete.")
    termux_notify_remove(PROCEDURE_NOTIF_ID)
    write_state(_segment_snapshot(procedure, run_id, n, 0, mode="idle"))
    return "completed"


# --------------------------------------------------------------------------
# Curses TUI
# --------------------------------------------------------------------------

def _safe_addstr(stdscr, row, col, text, width, attr=curses.A_NORMAL):
    try:
        stdscr.addstr(row, col, text[:max(width - col - 1, 0)], attr)
    except curses.error:
        pass


BANNER_LABELS = {
    "alarm_ringing": "ALARM RINGING",
    "grace_period": "GET READY",
}


def _render_banner(stdscr, snapshot, h, w):
    banner = BANNER_LABELS.get(snapshot.get("mode"), snapshot.get("mode", "").upper())
    title = snapshot.get("procedure_name") or ""
    detail = snapshot.get("detail") or ""
    clock = time.strftime("%H:%M:%S")
    _safe_addstr(stdscr, 0, 0, clock, w)

    mid = h // 2
    _safe_addstr(stdscr, max(mid - 3, 1), 0, banner.center(w), w, curses.A_BOLD | curses.A_REVERSE)
    if title:
        _safe_addstr(stdscr, max(mid - 1, 2), 0, title.center(w), w, curses.A_BOLD)
    if detail:
        _safe_addstr(stdscr, mid, 0, detail.center(w), w)

    remaining = snapshot.get("remaining_seconds") or 0
    if remaining > 0:
        rm, rs = divmod(int(remaining), 60)
        _safe_addstr(stdscr, mid + 2, 0, f"{rm:02d}:{rs:02d}".center(w), w, curses.A_BOLD)

    _safe_addstr(stdscr, h - 2, 0, "[s] dismiss   [q] abort".center(w), w)
    stdscr.refresh()


def render(stdscr, snapshot):
    stdscr.erase()
    h, w = stdscr.getmaxyx()

    if snapshot is None:
        _safe_addstr(stdscr, 0, 0, "phone-routine: no active run.", w)
        _safe_addstr(stdscr, 2, 0, "Press q to exit.", w)
        stdscr.refresh()
        return

    segs = snapshot.get("segments", [])
    if snapshot.get("mode") in BANNER_LABELS or not segs:
        _render_banner(stdscr, snapshot, h, w)
        return

    mode = snapshot.get("mode", "?")
    name = snapshot.get("procedure_name", "?")
    clock = time.strftime("%H:%M:%S")
    _safe_addstr(stdscr, 0, 0, f"{name}  [{mode}]  {clock}", w, curses.A_BOLD)

    cur = snapshot.get("current_index", 0)
    visible_rows = max(h - 6, 1)
    start = max(0, min(cur - visible_rows // 2, max(len(segs) - visible_rows, 0)))
    end = min(len(segs), start + visible_rows)

    row = 2
    if start > 0:
        _safe_addstr(stdscr, row, 0, f"  ... {start} more above", w)
        row += 1
    for i in range(start, end):
        seg = segs[i]
        status = seg.get("status")
        marker = ">" if i == cur else ("x" if status == "done" else " ")
        mins, secs = divmod(int(seg.get("duration_seconds", 0)), 60)
        label_w = max(w - 16, 1)
        label = seg.get("text", "")[:label_w].ljust(label_w)
        line = f"{marker} {label} {mins:02d}:{secs:02d}"
        if i == cur:
            attr = curses.A_REVERSE | curses.A_BOLD
        elif status == "done":
            attr = curses.A_DIM
        else:
            attr = curses.A_NORMAL
        _safe_addstr(stdscr, row, 0, line, w, attr)
        row += 1
    if end < len(segs):
        _safe_addstr(stdscr, row, 0, f"  ... {len(segs) - end} more below", w)
        row += 1

    row += 1
    remaining = int(snapshot.get("remaining_seconds", 0))
    rm, rs = divmod(remaining, 60)
    _safe_addstr(stdscr, min(row, h - 2), 0, f"TIME REMAINING: {rm:02d}:{rs:02d}", w, curses.A_BOLD)
    _safe_addstr(stdscr, min(row + 2, h - 1), 0, "[s] skip segment   [q] abort", w)
    stdscr.refresh()


def _make_curses_tick_hook(stdscr):
    def hook(snapshot):
        render(stdscr, snapshot)
        try:
            key = stdscr.getch()
        except curses.error:
            key = -1
        if key in (ord("s"), ord("n")):
            write_signal("skip")
        elif key == ord("q"):
            write_signal("abort")
    return hook


def _run_with_curses(stdscr, procedure, run_id, config):
    curses.curs_set(0)
    stdscr.timeout(int(config.get("tick_seconds", 0.2) * 1000))
    hook = _make_curses_tick_hook(stdscr)
    return run_procedure_segments(procedure, run_id, config, tick_hook=hook)


def _attach_curses(stdscr):
    curses.curs_set(0)
    stdscr.timeout(300)
    while True:
        snapshot = read_state()
        render(stdscr, snapshot)
        try:
            key = stdscr.getch()
        except curses.error:
            key = -1
        if key in (ord("s"), ord("n")):
            write_signal("skip")
        elif key == ord("q"):
            write_signal("abort")
            break
        elif key == 27:  # ESC: leave the viewer without touching the run
            break


# --------------------------------------------------------------------------
# Procedure runner (public entry point — acquires its own lock)
# --------------------------------------------------------------------------

def run_procedure(procedure, config=None, tui=True, kind="standalone"):
    config = config or load_config()
    run_id = acquire_lock(kind)
    try:
        if tui and sys.stdout.isatty():
            result = curses.wrapper(lambda stdscr: _run_with_curses(stdscr, procedure, run_id, config))
        else:
            result = run_procedure_segments(procedure, run_id, config)
        log(f"procedure {procedure.name!r} finished: {result}")
        return result
    finally:
        release_lock()


def pick_procedure_via_fzy(procedures):
    lines = "\n".join(f"{p.id}\t{p.name}" for p in procedures)
    try:
        result = subprocess.run(["fzy"], input=lines, capture_output=True, text=True)
    except FileNotFoundError:
        print("fzy not found; pass a procedure id directly", file=sys.stderr)
        return None
    chosen = result.stdout.strip()
    if result.returncode != 0 or not chosen:
        return None
    chosen_id = chosen.split("\t", 1)[0]
    try:
        return find_procedure_by_id(procedures, chosen_id)
    except DataError:
        return None


# --------------------------------------------------------------------------
# Scheduling: a long-running daemon sleeps until wake time (started at boot
# and left running indefinitely, re-reading tomorrow*.json fresh every
# cycle), backed by a periodic termux-job-scheduler job that just checks the
# daemon is still alive and relaunches it if not. See termux_job_schedule_
# periodic() above for why this two-part shape exists instead of a single
# scheduled job.
# --------------------------------------------------------------------------

def write_heartbeat():
    _atomic_write_json(HEARTBEAT_FILE, {"pid": os.getpid(), "updated_at": time.time()})


def read_heartbeat():
    try:
        return json.loads(HEARTBEAT_FILE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def read_fired_marker():
    try:
        return json.loads(FIRED_MARKER_FILE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def write_fired_marker(wake_dt):
    _atomic_write_json(FIRED_MARKER_FILE, {
        "wake_at": wake_dt.isoformat(),
        "fired_at": datetime.now().isoformat(),
    })


def _daemon_heartbeat_is_stale(config):
    hb = read_heartbeat()
    if not hb:
        return True
    age = time.time() - hb.get("updated_at", 0)
    if age > config.get("daemon_stale_seconds", 180):
        return True
    try:
        os.kill(hb.get("pid"), 0)
    except (ProcessLookupError, TypeError):
        return True
    return False


def launch_daemon_detached():
    self_path = resolve_self_path()
    subprocess.Popen(
        [self_path, "wakeup-daemon"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL,
        start_new_session=True,
    )
    log("launched wakeup-daemon")


def ensure_daemon_running(config):
    if _daemon_heartbeat_is_stale(config):
        launch_daemon_detached()
        return True
    return False


def _daemon_lock_acquire():
    CONTROL_DIR.mkdir(parents=True, exist_ok=True)
    for _ in range(2):
        try:
            fd = os.open(str(DAEMON_LOCK_FILE), os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o644)
        except FileExistsError:
            try:
                existing = json.loads(DAEMON_LOCK_FILE.read_text())
                os.kill(existing.get("pid"), 0)
                return False  # another daemon is genuinely alive
            except ProcessLookupError:
                log("wakeup-daemon: stealing stale daemon lock (dead pid)")
            except (OSError, ValueError, TypeError, json.JSONDecodeError):
                log("wakeup-daemon: daemon lock unreadable, stealing")
            try:
                DAEMON_LOCK_FILE.unlink()
            except FileNotFoundError:
                pass
            continue
        with os.fdopen(fd, "w") as f:
            json.dump({"pid": os.getpid(), "started_at": time.time()}, f)
        return True
    return False


def _daemon_lock_release():
    try:
        DAEMON_LOCK_FILE.unlink()
    except FileNotFoundError:
        pass


def wakeup_daemon(config):
    if not _daemon_lock_acquire():
        log("wakeup-daemon: another daemon instance is already running, exiting")
        return 1
    log("wakeup-daemon: starting")
    termux_wake_lock()  # held for the daemon's whole lifetime -- battery
    # cost accepted deliberately so Doze can't silently stall the sleep-
    # until-wake-time loop; this is what makes the daemon precise.
    tick = config.get("daemon_tick_seconds", 30)
    marker = read_fired_marker()
    last_fired_for = marker.get("wake_at") if marker else None
    try:
        while True:
            try:
                wake_dt = load_wakeup_time()
            except DataError as e:
                log(f"wakeup-daemon: {e} (retrying in 60s)")
                write_heartbeat()
                time.sleep(60)
                continue
            wake_iso = wake_dt.isoformat()
            if wake_iso == last_fired_for:
                # already handled this exact wake time; wait for
                # tomorrow*.json to be regenerated with a new one.
                write_heartbeat()
                time.sleep(tick)
                continue
            remaining = (wake_dt - datetime.now()).total_seconds()
            if remaining <= 0:
                log(f"wakeup-daemon: firing alarm for {wake_dt}")
                write_fired_marker(wake_dt)
                last_fired_for = wake_iso
                try:
                    fire_wakeup(config)
                except Exception as e:
                    # An uncaught exception here would otherwise kill the
                    # whole daemon (silently, until the 15min backstop
                    # notices and relaunches it) -- for an alarm clock,
                    # logging and continuing the loop is much better than
                    # dying on some unrelated failure mid-flow.
                    log(f"wakeup-daemon: fire_wakeup raised: {e!r}")
                continue
            write_heartbeat()
            time.sleep(min(remaining, tick))
    finally:
        _daemon_lock_release()
        termux_wake_unlock()


# --------------------------------------------------------------------------
# Alarm flow
# --------------------------------------------------------------------------

def fire_wakeup(config):
    log("wakeup-fire: starting")
    termux_wake_lock()
    try:
        run_id = acquire_lock("wakeup")
    except LockError as e:
        log(f"wakeup-fire: {e}")
        termux_wake_unlock()
        return 1

    try:
        duration = ensure_tone_cached(config)

        # Primary interface: pop a visible Termux session showing the alarm
        # state, same as during a procedure. Notifications (below) mirror
        # this state and offer a quick-action button, but are secondary --
        # best-effort, since Android background-activity-start restrictions
        # can block the popup on some devices/OEMs.
        write_state(_banner_snapshot(run_id, "alarm_ringing", "Wake up", "Press s to dismiss the alarm"))
        launch_visible_session(resolve_self_path(), ["attach"])

        termux_notify(
            ALARM_NOTIF_ID, "Wake up", "Tap \"I'm up\" to stop the alarm",
            ongoing=True, button1="I'm up", button1_action=f"{resolve_self_path()} signal ack",
            priority="max",
        )
        aborted = False
        last_play = 0.0
        while True:
            action = consume_signal(run_id)
            if action in ADVANCE_ACTIONS:
                break
            if action in ABORT_ACTIONS:
                aborted = True
                break
            now = time.monotonic()
            if now - last_play >= duration:
                termux_media_play(TONE_FILE)
                last_play = now
            write_state(_banner_snapshot(run_id, "alarm_ringing", "Wake up", "Press s to dismiss the alarm"))
            time.sleep(0.2)
        termux_media_stop()
        termux_notify_remove(ALARM_NOTIF_ID)
        if aborted:
            log("wakeup-fire: aborted during tone")
            write_state(_banner_snapshot(run_id, "idle", "Alarm aborted", ""))
            return 0

        grace_seconds = config.get("grace_period_seconds", 60)
        grace_start = time.monotonic()
        last_notify = 0.0
        while True:
            elapsed = time.monotonic() - grace_start
            remaining = grace_seconds - elapsed
            if remaining <= 0:
                break
            action = consume_signal(run_id)
            if action in ADVANCE_ACTIONS:
                break
            if action in ABORT_ACTIONS:
                aborted = True
                break
            now = time.monotonic()
            if now - last_notify >= 2:
                termux_notify(
                    GRACE_NOTIF_ID, "Get ready", f"Put in earbuds - {int(remaining)}s",
                    ongoing=True, button1="Skip", button1_action=f"{resolve_self_path()} signal skip-grace",
                    priority="max",
                )
                last_notify = now
            write_state(_banner_snapshot(
                run_id, "grace_period", "Get ready", "Put in your earbuds -- press s to skip",
                remaining_seconds=remaining,
            ))
            time.sleep(0.3)
        termux_notify_remove(GRACE_NOTIF_ID)
        if aborted:
            log("wakeup-fire: aborted during grace period")
            write_state(_banner_snapshot(run_id, "idle", "Alarm aborted", ""))
            return 0

        try:
            procedures = load_procedures()
            routine = find_morning_routine(procedures, config.get("morning_routine_name_substring", "Morning"))
        except DataError as e:
            log(f"wakeup-fire: could not resolve morning routine: {e}")
            termux_notify(ALARM_NOTIF_ID, "phone-routine error", str(e))
            write_state(_banner_snapshot(run_id, "idle", "Error", str(e)))
            return 1

        # The visible session popped up at the start of the alarm is still
        # showing (attach re-reads state.json every tick, so it follows the
        # mode transition into running_procedure automatically) -- no need
        # to relaunch it here.
        result = run_procedure_segments(routine, run_id, config)
        log(f"wakeup-fire: morning routine result: {result}")
        return 0
    finally:
        release_lock()
        termux_wake_unlock()


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

REQUIRED_BINARIES = [
    "termux-notification", "termux-notification-remove", "espeak",
    "termux-media-player", "termux-job-scheduler", "termux-wake-lock",
    "termux-wake-unlock", "am", "fzy",
]


def cmd_wakeup_arm():
    config = load_config()
    self_path = resolve_self_path()
    checker_path = shutil.which("phone-routine-wakeup-check") or str(HOME / ".local" / "bin" / "phone-routine-wakeup-check")
    job_id = config.get("job_id", 4200)
    termux_job_cancel(job_id)  # defensive: ensure a clean re-registration
    termux_job_schedule_periodic(job_id, checker_path, config.get("backstop_period_ms", 900000))
    ensure_daemon_running(config)
    log("wakeup-arm: backstop job registered, daemon ensured running")
    return 0


def cmd_wakeup_check():
    # Invoked periodically (>=15min) by the termux-job-scheduler backstop
    # job -- just revives wakeup-daemon if its heartbeat has gone stale.
    ensure_daemon_running(load_config())
    return 0


def cmd_wakeup_daemon():
    return wakeup_daemon(load_config())


def cmd_wakeup_fire():
    return fire_wakeup(load_config())


def cmd_run_procedure(procedure_id):
    config = load_config()
    try:
        procedures = load_procedures()
    except DataError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    if procedure_id:
        try:
            proc = find_procedure_by_id(procedures, procedure_id)
        except DataError as e:
            print(f"error: {e}", file=sys.stderr)
            return 1
    else:
        proc = pick_procedure_via_fzy(procedures)
        if proc is None:
            print("no procedure selected", file=sys.stderr)
            return 1
    try:
        run_procedure(proc, config=config, tui=True, kind="standalone")
    except LockError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0


def cmd_attach():
    curses.wrapper(_attach_curses)
    return 0


def cmd_signal(action):
    write_signal(action)
    return 0


def cmd_wakeup_status():
    config = load_config()
    ok = True
    try:
        wake_dt = load_wakeup_time()
        print(f"next wakeup (from data): {wake_dt}")
    except DataError as e:
        print(f"wakeup time unavailable: {e}")
        ok = False

    hb = read_heartbeat()
    if hb:
        age = int(time.time() - hb.get("updated_at", 0))
        stale = _daemon_heartbeat_is_stale(config)
        print(f"daemon: {'STALE' if stale else 'running'} (pid {hb.get('pid')}, heartbeat {age}s ago)")
        ok = ok and not stale
    else:
        print("daemon: not running (no heartbeat yet)")
        ok = False

    marker = read_fired_marker()
    if marker:
        print(f"last fired: {marker.get('wake_at')} (at {marker.get('fired_at')})")

    return 0 if ok else 1


def cmd_doctor():
    ok = True
    print("phone-routine doctor")
    print(f"  self: {shutil.which('phone-routine') or '(not on PATH)'}")
    for b in REQUIRED_BINARIES:
        found = shutil.which(b)
        status = "OK" if found else "MISSING"
        print(f"  [{status}] {b}" + (f" -> {found}" if found else ""))
        if not found:
            ok = False

    config = load_config()
    print(f"  [OK] config loaded ({CONFIG_FILE if CONFIG_FILE.exists() else 'defaults'})")

    try:
        wake = load_wakeup_time()
        print(f"  [OK] wakeup time: {wake}")
    except DataError as e:
        print(f"  [FAIL] wakeup time: {e}")
        ok = False

    try:
        procedures = load_procedures()
        print(f"  [OK] procedures loaded: {len(procedures)}")
        routine = find_morning_routine(procedures, config.get("morning_routine_name_substring", "Morning"))
        print(f"  [OK] morning routine: {routine.name} ({len(routine.segments)} segments)")
    except DataError as e:
        print(f"  [FAIL] procedures: {e}")
        ok = False

    return 0 if ok else 1


def cmd_tone_test():
    config = load_config()
    duration = ensure_tone_cached(config)
    print(f"playing synthesized tone ({duration:.2f}s): {TONE_FILE}")
    termux_media_play(TONE_FILE)
    return 0


def build_parser():
    parser = argparse.ArgumentParser(prog="phone-routine")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("wakeup-arm", help="register the backstop job and ensure wakeup-daemon is running")
    sub.add_parser("wakeup-daemon", help="long-running: sleeps until wake time, fires the alarm, repeats")
    sub.add_parser("wakeup-check", help="internal: invoked by the backstop job to revive a dead daemon")
    sub.add_parser("wakeup-fire", help="manually trigger the alarm flow now (for testing)")
    rp = sub.add_parser("run-procedure", help="run a procedure standalone (menu if no id given)")
    rp.add_argument("procedure_id", nargs="?")
    sub.add_parser("attach", help="curses viewer for a currently-running procedure")
    sg = sub.add_parser("signal", help="internal: send a control signal to the active run")
    sg.add_argument("action", choices=sorted(ADVANCE_ACTIONS | ABORT_ACTIONS))
    sub.add_parser("wakeup-status", help="show the currently armed alarm, if any")
    sub.add_parser("doctor", help="pre-flight check of termux-api binaries and data files")
    sub.add_parser("tone-test", help="play the synthesized alarm tone once")
    return parser


def main(argv=None):
    # termux-job-scheduler --script has no way to pass arguments, so the
    # wakeup-check entry point (invoked by the periodic backstop job) is
    # dispatched by executable name instead: the Makefile installs a
    # `phone-routine-wakeup-check` symlink to this file.
    prog_basename = os.path.basename(sys.argv[0])
    if prog_basename == "phone-routine-wakeup-check":
        return cmd_wakeup_check()

    parser = build_parser()
    args = parser.parse_args(sys.argv[1:] if argv is None else argv)

    if args.command == "wakeup-arm":
        return cmd_wakeup_arm()
    if args.command == "wakeup-daemon":
        return cmd_wakeup_daemon()
    if args.command == "wakeup-check":
        return cmd_wakeup_check()
    if args.command == "wakeup-fire":
        return cmd_wakeup_fire()
    if args.command == "run-procedure":
        return cmd_run_procedure(args.procedure_id)
    if args.command == "attach":
        return cmd_attach()
    if args.command == "signal":
        return cmd_signal(args.action)
    if args.command == "wakeup-status":
        return cmd_wakeup_status()
    if args.command == "doctor":
        return cmd_doctor()
    if args.command == "tone-test":
        return cmd_tone_test()
    parser.error("unknown command")


if __name__ == "__main__":
    raise SystemExit(main())
