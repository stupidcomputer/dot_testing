#!/usr/bin/env python3
"""Receive JSON-line evdev events on stdin and replay them via uinput.

Run this on the desktop side, typically as root:
    sudo python3 ./server.py

Intended transport:
    sudo ./client.py ... | ssh desktop 'sudo python3 /path/to/server.py'
"""

from __future__ import annotations

import json
import sys
from typing import Iterable

from evdev import UInput, ecodes


def all_key_codes() -> list[int]:
    # Advertise the real EV_KEY/BTN code range accepted by the kernel.
    # Using every ecodes name pulls in helper constants like KEY_MAX/KEY_CNT,
    # which some kernels reject during uinput setup.
    return list(range(1, ecodes.KEY_MAX + 1))


SUPPORTED_REL_CODES = [
    ecodes.REL_X,
    ecodes.REL_Y,
    ecodes.REL_WHEEL,
    ecodes.REL_HWHEEL,
]


CAPABILITIES = {
    ecodes.EV_KEY: all_key_codes(),
    ecodes.EV_REL: SUPPORTED_REL_CODES,
}


class InputReplayer:
    def __init__(self) -> None:
        self.ui = UInput(CAPABILITIES, name="ssh-kvm prototype", version=0x1)
        self.pressed_keys: set[int] = set()

    def close(self) -> None:
        self.release_all()
        self.ui.close()

    def release_all(self) -> None:
        if not self.pressed_keys:
            return
        for code in sorted(self.pressed_keys):
            self.ui.write(ecodes.EV_KEY, code, 0)
        self.ui.syn()
        self.pressed_keys.clear()

    def handle_event(self, event_type: int, code: int, value: int) -> None:
        if event_type == ecodes.EV_SYN:
            if code == ecodes.SYN_REPORT:
                self.ui.syn()
            return

        if event_type == ecodes.EV_KEY:
            if not 1 <= code <= ecodes.KEY_MAX:
                return
            if value == 0:
                self.pressed_keys.discard(code)
            else:
                self.pressed_keys.add(code)
        elif event_type == ecodes.EV_REL:
            if code not in SUPPORTED_REL_CODES:
                return

        self.ui.write(event_type, code, value)

    def handle_control(self, action: str) -> None:
        if action == "release_all":
            self.release_all()



def message_stream(lines: Iterable[str]):
    for raw in lines:
        raw = raw.strip()
        if not raw:
            continue
        yield json.loads(raw)



def main(_argv: list[str] | None = None) -> int:
    replayer = InputReplayer()
    try:
        for message in message_stream(sys.stdin):
            kind = message.get("kind")
            if kind == "hello":
                continue
            if kind == "control":
                replayer.handle_control(str(message.get("action", "")))
                continue
            if kind != "event":
                continue

            replayer.handle_event(
                int(message["type"]),
                int(message["code"]),
                int(message["value"]),
            )
    finally:
        replayer.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
