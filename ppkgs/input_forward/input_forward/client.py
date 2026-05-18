#!/usr/bin/env python3
"""Capture local evdev keyboard/mouse events and stream them as JSON lines.

Intended usage:
    sudo ./client.py --keyboard /dev/input/by-id/...-kbd --mouse /dev/input/by-id/...-mouse \
      | ssh desktop 'sudo python3 /path/to/server.py'

Current prototype notes:
- Keyboard forwarding works at the evdev layer, so Super/i3 keybinds survive.
- Mouse support works for relative mice/trackpoints.
- Basic touchpad support translates absolute finger motion into relative pointer motion.
- Press LeftCtrl+RightCtrl+Esc locally to stop forwarding.
"""

from __future__ import annotations

import argparse
import json
import math
import select
import signal
import sys
from dataclasses import dataclass
from typing import Iterable

from evdev import AbsInfo, InputDevice, ecodes

STOP_CHORD = {ecodes.KEY_LEFTCTRL, ecodes.KEY_RIGHTCTRL}
STOP_KEY = ecodes.KEY_ESC
ALLOWED_EVENT_TYPES = {ecodes.EV_KEY, ecodes.EV_REL, ecodes.EV_SYN, ecodes.EV_ABS}
IGNORED_SYN_CODES = {ecodes.SYN_DROPPED}
TOUCH_STATE_CODES = {
    ecodes.BTN_TOUCH,
    ecodes.BTN_TOOL_FINGER,
    ecodes.BTN_TOOL_DOUBLETAP,
    ecodes.BTN_TOOL_TRIPLETAP,
    ecodes.BTN_TOOL_QUADTAP,
    ecodes.BTN_TOOL_QUINTTAP,
}
TOUCH_TOOL_CODE_TO_FINGERS = {
    ecodes.BTN_TOOL_FINGER: 1,
    ecodes.BTN_TOOL_DOUBLETAP: 2,
    ecodes.BTN_TOOL_TRIPLETAP: 3,
    ecodes.BTN_TOOL_QUADTAP: 4,
    ecodes.BTN_TOOL_QUINTTAP: 5,
}
TOUCHPAD_REL_COUNTS_PER_MM = 8.0
TOUCHPAD_SCROLL_NOTCHES_PER_MM = 0.18
TOUCHPAD_FALLBACK_FULL_TRAVEL_COUNTS = 800.0
TOUCHPAD_FALLBACK_FULL_TRAVEL_SCROLL_NOTCHES = 80.0


@dataclass
class TouchpadTranslator:
    abs_x_code: int
    abs_y_code: int
    x_info: AbsInfo
    y_info: AbsInfo
    mt_only: bool
    active_slots: set[int]
    slot_positions: dict[int, tuple[int | None, int | None]]
    current_slot: int = 0
    touch_active: bool = False
    finger_count: int = 0
    saw_explicit_touch_state: bool = False
    rebase_on_next_sync: bool = False
    current_x: float | None = None
    current_y: float | None = None
    last_x: float | None = None
    last_y: float | None = None
    last_mode: str | None = None
    carry_x: float = 0.0
    carry_y: float = 0.0
    carry_scroll_x: float = 0.0
    carry_scroll_y: float = 0.0

    def __init__(self, abs_x_code: int, abs_y_code: int, x_info: AbsInfo, y_info: AbsInfo, *, mt_only: bool) -> None:
        self.abs_x_code = abs_x_code
        self.abs_y_code = abs_y_code
        self.x_info = x_info
        self.y_info = y_info
        self.mt_only = mt_only
        self.active_slots = set()
        self.slot_positions = {}

    def reset_reference(self) -> None:
        self.last_x = self.current_x
        self.last_y = self.current_y
        self.carry_x = 0.0
        self.carry_y = 0.0
        self.carry_scroll_x = 0.0
        self.carry_scroll_y = 0.0

    def note_key(self, code: int, value: int) -> bool:
        if code not in TOUCH_STATE_CODES:
            return False

        self.saw_explicit_touch_state = True
        was_active = self.touch_active
        previous_finger_count = self.finger_count

        if code == ecodes.BTN_TOUCH:
            self.touch_active = value != 0
            if not self.touch_active:
                self.finger_count = 0
            elif self.finger_count == 0:
                self.finger_count = 1
        elif code in TOUCH_TOOL_CODE_TO_FINGERS:
            if value:
                self.finger_count = TOUCH_TOOL_CODE_TO_FINGERS[code]
                self.touch_active = True
            elif self.finger_count == TOUCH_TOOL_CODE_TO_FINGERS[code]:
                self.finger_count = 0
                self.touch_active = False

        if self.touch_active != was_active or self.finger_count != previous_finger_count:
            self.rebase_on_next_sync = True
            self.last_mode = None
        if not self.touch_active:
            self.reset_reference()
        return True

    def note_abs(self, code: int, value: int) -> bool:
        if self.mt_only and code == ecodes.ABS_MT_SLOT:
            self.current_slot = value
            return True

        if self.mt_only and code == ecodes.ABS_MT_TRACKING_ID:
            self.saw_explicit_touch_state = True
            was_active = self.touch_active
            if value < 0:
                self.active_slots.discard(self.current_slot)
                self.slot_positions.pop(self.current_slot, None)
            else:
                self.active_slots.add(self.current_slot)
                self.slot_positions.setdefault(self.current_slot, (None, None))
            self.touch_active = bool(self.active_slots)
            self.finger_count = len(self.active_slots)
            if self.touch_active != was_active:
                self.rebase_on_next_sync = True
                self.last_mode = None
            if not self.touch_active:
                self.reset_reference()
            return True

        if self.mt_only:
            slot_x, slot_y = self.slot_positions.get(self.current_slot, (None, None))
            if code == self.abs_x_code:
                self.slot_positions[self.current_slot] = (value, slot_y)
                return True
            if code == self.abs_y_code:
                self.slot_positions[self.current_slot] = (slot_x, value)
                return True
            return False

        if code == self.abs_x_code:
            self.current_x = float(value)
            return True
        if code == self.abs_y_code:
            self.current_y = float(value)
            return True
        return False

    def flush(self) -> list[tuple[int, int, int]]:
        current_point, mode = self._current_point_and_mode()
        if current_point is None:
            return []

        self.current_x, self.current_y = current_point

        if not self.touch_active and self.saw_explicit_touch_state:
            self.last_mode = None
            self.reset_reference()
            return []

        if self.rebase_on_next_sync or self.last_mode != mode:
            self.rebase_on_next_sync = False
            self.last_mode = mode
            self.reset_reference()
            return []

        if self.last_x is None or self.last_y is None:
            self.last_mode = mode
            self.reset_reference()
            return []

        dx = self.current_x - self.last_x
        dy = self.current_y - self.last_y
        self.last_x = self.current_x
        self.last_y = self.current_y
        self.last_mode = mode

        if mode == "scroll":
            wheel_x = self._scale_scroll(dx, axis="x")
            wheel_y = self._scale_scroll(-dy, axis="y")
            events: list[tuple[int, int, int]] = []
            if wheel_y:
                events.append((ecodes.EV_REL, ecodes.REL_WHEEL, wheel_y))
            if wheel_x:
                events.append((ecodes.EV_REL, ecodes.REL_HWHEEL, wheel_x))
            return events

        rel_x = self._scale_pointer_delta(dx, axis="x")
        rel_y = self._scale_pointer_delta(dy, axis="y")
        events = []
        if rel_x:
            events.append((ecodes.EV_REL, ecodes.REL_X, rel_x))
        if rel_y:
            events.append((ecodes.EV_REL, ecodes.REL_Y, rel_y))
        return events

    def _current_point_and_mode(self) -> tuple[tuple[float, float] | None, str | None]:
        if not self.mt_only:
            if self.current_x is None or self.current_y is None:
                return None, None
            mode = "scroll" if self.finger_count >= 2 else "pointer"
            return (self.current_x, self.current_y), mode

        points = [
            (float(x), float(y))
            for slot in sorted(self.active_slots)
            for x, y in [self.slot_positions.get(slot, (None, None))]
            if x is not None and y is not None
        ]
        if not points:
            return None, None

        avg_x = sum(x for x, _ in points) / len(points)
        avg_y = sum(y for _, y in points) / len(points)
        if len(points) >= 2:
            return (avg_x, avg_y), "scroll"
        return (avg_x, avg_y), "pointer"

    def _scale_pointer_delta(self, delta: float, *, axis: str) -> int:
        if delta == 0:
            return 0

        info = self.x_info if axis == "x" else self.y_info
        carry_attr = "carry_x" if axis == "x" else "carry_y"
        units_per_rel = self._units_per_pointer_count(info)
        total = getattr(self, carry_attr) + (delta / units_per_rel)

        if total >= 0:
            whole = math.floor(total)
        else:
            whole = math.ceil(total)

        setattr(self, carry_attr, total - whole)
        return whole

    def _scale_scroll(self, delta: float, *, axis: str) -> int:
        if delta == 0:
            return 0

        info = self.x_info if axis == "x" else self.y_info
        carry_attr = "carry_scroll_x" if axis == "x" else "carry_scroll_y"
        units_per_notch = self._units_per_scroll_notch(info)
        total = getattr(self, carry_attr) + (delta / units_per_notch)

        if total >= 0:
            whole = math.floor(total)
        else:
            whole = math.ceil(total)

        setattr(self, carry_attr, total - whole)
        return whole

    def _units_per_pointer_count(self, info: AbsInfo) -> float:
        if info.resolution and info.resolution > 0:
            return max(info.resolution / TOUCHPAD_REL_COUNTS_PER_MM, 1.0)
        span = max(info.max - info.min, 1)
        return max(span / TOUCHPAD_FALLBACK_FULL_TRAVEL_COUNTS, 1.0)

    def _units_per_scroll_notch(self, info: AbsInfo) -> float:
        if info.resolution and info.resolution > 0:
            return max(info.resolution / TOUCHPAD_SCROLL_NOTCHES_PER_MM, 1.0)
        span = max(info.max - info.min, 1)
        return max(span / TOUCHPAD_FALLBACK_FULL_TRAVEL_SCROLL_NOTCHES, 1.0)


@dataclass
class ManagedDevice:
    path: str
    role: str
    dev: InputDevice
    touchpad: TouchpadTranslator | None = None


class EventStreamer:
    def __init__(self, devices: list[ManagedDevice], grab: bool) -> None:
        self.devices = devices
        self.grab = grab
        self.keyboard_pressed: set[int] = set()
        self._stop = False

    def request_stop(self, *_args: object) -> None:
        self._stop = True

    def open(self) -> None:
        for managed in self.devices:
            if self.grab:
                managed.dev.grab()

    def close(self) -> None:
        for managed in self.devices:
            try:
                if self.grab:
                    managed.dev.ungrab()
            except OSError:
                pass
            try:
                managed.dev.close()
            except OSError:
                pass

    def send_message(self, payload: dict[str, object]) -> None:
        sys.stdout.write(json.dumps(payload, separators=(",", ":")) + "\n")
        sys.stdout.flush()

    def note_key_state(self, event_code: int, event_value: int) -> None:
        if event_value == 1:
            self.keyboard_pressed.add(event_code)
        elif event_value == 0:
            self.keyboard_pressed.discard(event_code)

    def stop_chord_pressed(self, event_code: int, event_value: int) -> bool:
        return (
            event_code == STOP_KEY
            and event_value == 1
            and STOP_CHORD.issubset(self.keyboard_pressed)
        )

    def send_event(self, managed: ManagedDevice, event_type: int, code: int, value: int) -> None:
        self.send_message(
            {
                "kind": "event",
                "type": event_type,
                "code": code,
                "value": value,
                "source": managed.role,
            }
        )

    def handle_touchpad_event(self, managed: ManagedDevice, event) -> bool:
        touchpad = managed.touchpad
        if touchpad is None:
            return False

        if event.type == ecodes.EV_KEY and touchpad.note_key(event.code, event.value):
            return True

        if event.type == ecodes.EV_ABS and touchpad.note_abs(event.code, event.value):
            return True

        if event.type == ecodes.EV_SYN and event.code == ecodes.SYN_REPORT:
            for event_type, code, value in touchpad.flush():
                self.send_event(managed, event_type, code, value)
            return False

        return False

    def stream(self) -> int:
        self.send_message(
            {
                "kind": "hello",
                "protocol": 1,
                "devices": [
                    {
                        "path": managed.path,
                        "role": managed.role,
                        "name": managed.dev.name,
                        "touchpad": managed.touchpad is not None,
                    }
                    for managed in self.devices
                ],
            }
        )

        fd_to_device = {managed.dev.fd: managed for managed in self.devices}

        while not self._stop:
            readable, _, _ = select.select(list(fd_to_device), [], [], 0.25)
            if not readable:
                continue

            for fd in readable:
                managed = fd_to_device[fd]
                for event in managed.dev.read():
                    if event.type not in ALLOWED_EVENT_TYPES:
                        continue
                    if event.type == ecodes.EV_SYN and event.code in IGNORED_SYN_CODES:
                        continue

                    if managed.role == "keyboard" and event.type == ecodes.EV_KEY:
                        self.note_key_state(event.code, event.value)
                        if self.stop_chord_pressed(event.code, event.value):
                            self.send_message({"kind": "control", "action": "release_all"})
                            return 0

                    if managed.role == "mouse" and self.handle_touchpad_event(managed, event):
                        continue

                    self.send_event(managed, event.type, event.code, event.value)

        self.send_message({"kind": "control", "action": "release_all"})
        return 0


def detect_touchpad(dev: InputDevice) -> TouchpadTranslator | None:
    capabilities = dev.capabilities(absinfo=True)
    abs_caps = capabilities.get(ecodes.EV_ABS, [])
    abs_info_by_code = {
        code: info
        for code, info in abs_caps
        if isinstance(code, int) and isinstance(info, AbsInfo)
    }

    if ecodes.ABS_X in abs_info_by_code and ecodes.ABS_Y in abs_info_by_code:
        return TouchpadTranslator(
            ecodes.ABS_X,
            ecodes.ABS_Y,
            abs_info_by_code[ecodes.ABS_X],
            abs_info_by_code[ecodes.ABS_Y],
            mt_only=False,
        )

    if (
        ecodes.ABS_MT_POSITION_X in abs_info_by_code
        and ecodes.ABS_MT_POSITION_Y in abs_info_by_code
    ):
        return TouchpadTranslator(
            ecodes.ABS_MT_POSITION_X,
            ecodes.ABS_MT_POSITION_Y,
            abs_info_by_code[ecodes.ABS_MT_POSITION_X],
            abs_info_by_code[ecodes.ABS_MT_POSITION_Y],
            mt_only=True,
        )

    return None


def open_devices(paths: Iterable[str], role: str) -> list[ManagedDevice]:
    devices: list[ManagedDevice] = []
    for path in paths:
        dev = InputDevice(path)
        devices.append(
            ManagedDevice(
                path=path,
                role=role,
                dev=dev,
                touchpad=detect_touchpad(dev) if role == "mouse" else None,
            )
        )
    return devices


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--keyboard",
        action="append",
        default=[],
        help="Keyboard device path, ideally under /dev/input/by-id or /dev/input/by-path. Repeatable.",
    )
    parser.add_argument(
        "--mouse",
        action="append",
        default=[],
        help="Mouse device path. Relative mice work directly; basic absolute touchpad translation is also supported. Repeatable.",
    )
    parser.add_argument(
        "--no-grab",
        action="store_true",
        help="Do not EVIOCGRAB the local devices. Useful for debugging; not ideal for real use.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if not args.keyboard and not args.mouse:
        print("error: at least one --keyboard or --mouse device is required", file=sys.stderr)
        return 2

    devices = open_devices(args.keyboard, "keyboard") + open_devices(args.mouse, "mouse")
    streamer = EventStreamer(devices=devices, grab=not args.no_grab)

    signal.signal(signal.SIGINT, streamer.request_stop)
    signal.signal(signal.SIGTERM, streamer.request_stop)

    try:
        streamer.open()
        return streamer.stream()
    except BrokenPipeError:
        print("error: output pipe closed; remote ssh/server side exited", file=sys.stderr)
        return 1
    finally:
        streamer.close()


if __name__ == "__main__":
    raise SystemExit(main())
