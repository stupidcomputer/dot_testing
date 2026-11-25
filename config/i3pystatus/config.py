from i3pystatus import IntervalModule, Status
from i3pystatus.file import File
from dataclasses import dataclass
from socket import gethostname
import logging
import socket
import subprocess
import threading
import time
import urllib.parse
import urllib.request
from enum import Enum, auto
from datetime import date, datetime
from typing import Optional

class ScheduleItemState(Enum):
    BEFORE = auto()
    ACTIVE = auto()
    AFTER = auto()

@dataclass
class ScheduleItem:
    classname: str
    timestring: str
    roominfo: str = ""

    def __post_init__(self):
        day_date, day_name, timerange = self.timestring.split(' ')
        times = timerange.split('-')

        time_beginning = f"{day_date} {times[0]}"
        time_ending = f"{day_date} {times[1]}"
        time_format = "%Y-%m-%d %H:%M"

        self.beginning = datetime.strptime(time_beginning, time_format)
        self.ending = datetime.strptime(time_ending, time_format)

    def __repr__(self):
        return "<ScheduleItem, r->'{}' c->'{}', t_b->'{}', t_e->'{}'>".format(
            self.roominfo,
            self.classname,
            self.beginning,
            self.ending
        )

    def get_state(self, now):
        now_unix = now.timestamp()
        beginning_unix = self.beginning.timestamp()
        end_unix = self.ending.timestamp()

        if beginning_unix <= now_unix and now_unix <= end_unix:
            return ScheduleItemState.ACTIVE
        elif now_unix < beginning_unix:
            return ScheduleItemState.BEFORE
        elif now_unix > end_unix:
            return ScheduleItemState.AFTER

# the logfile is attached to the i3pystatus logger, which modules defined in
# this file don't inherit from
log = logging.getLogger("i3pystatus.config")
log.setLevel(logging.WARNING)

class ClassMonitor(IntervalModule):
    interval = 1
    output = ""

    _schedule_tag = "schoolschedule"
    _schedule_items: list[ScheduleItem] = []
    _current_schedule_item: Optional[ScheduleItem] = None
    _current_secs_left: int = 0
    _before_class = None
    _end_of_classes = False
    _first_run: bool = True
    _logged_missing: bool = False

    def _parse_schedule_line(self, line):
        # remove headline prefix
        first_meaningful_character = line.find(" ") + 1
        line = line[first_meaningful_character:]

        # the line should be formatted like:
        # {roominformation} classname <datespec> :scheduletag:
        # so we can transform "{", "}", "<", ">", and ":"
        # into a unique character and split on it to parse
        characters_to_replace = ["{", "}", "<", ">"]
        for character in characters_to_replace:
            line = line.replace(character, "\x1f")
        splitted = line.split("\x1f")

        # clean up the splitted data
        for index, item in enumerate(splitted):
            if item == "":
                del splitted[index]
                continue
            item = item.lstrip().rstrip()
            splitted[index] = item
        del splitted[-1]

        if len(splitted) == 3:
            return ScheduleItem(
                roominfo = splitted[0],
                classname = splitted[1],
                timestring = splitted[2]
            )
        elif len(splitted) == 2:
            return ScheduleItem(
                classname = splitted[0],
                timestring = splitted[1]
            )

    def _generate_schedule_specification(self):
        with open("/home/usr/org/agenda.org", "r") as file:
            contents = file.readlines()

        relevant_lines = []
        now = date.today().strftime("%Y-%m-%d")

        for line in contents:
            if not f":{self._schedule_tag}:" in line:
                continue
            elif ',' == line[0]:
                continue
            elif not now in line:
                continue

            line = line.rstrip()
            relevant_lines.append(line)

        schedule_items = []
        for line in relevant_lines:
            schedule_item = self._parse_schedule_line(line)
            if schedule_item:
                self._schedule_items.append(schedule_item)

    def _calculate_schedule_states(self, now):
        return [i.get_state(now) for i in self._schedule_items]

    def run(self):
        if self._first_run:
            try:
                self._generate_schedule_specification()
            except OSError as e:
                if not self._logged_missing:
                    log.warning("ClassMonitor: hiding: %s", e)
                    self._logged_missing = True
                return
            self._first_run = False

        if self._end_of_classes:
            self.output = {
                "full_text": ""
            }
            return

        now = datetime.now()
        if int(self._current_secs_left) == 0:
            next_class = None
            states = self._calculate_schedule_states(now)
            for index, state in enumerate(states):
                if state is ScheduleItemState.BEFORE and index == 0:
                    next_class = self._schedule_items[index]
                    break
                elif state is ScheduleItemState.ACTIVE:
                    next_class = self._schedule_items[index]
                    break
                elif state is ScheduleItemState.BEFORE and states[index - 1] is ScheduleItemState.AFTER:
                    next_class = self._schedule_items[index]
                    break
            if next_class is None:
                self._end_of_classes = True
                return

            self._current_schedule_item = next_class
            self._current_secs_left = next_class.ending.timestamp() - now.timestamp()

        # render the class
        pretty_seconds = int(self._current_secs_left % 60)
        pretty_minutes = int(self._current_secs_left / 60)
        current_class = self._current_schedule_item
        arrow = "<" if current_class.beginning.timestamp() - now.timestamp() > 0 else ">"
        class_name = current_class.classname
        output = f"{arrow}{pretty_minutes:02}:{pretty_seconds:02}"
        self.output = {
            "full_text": output
        }

        self._current_secs_left -= 1

class EmacsClock(File):
    _logged_missing: bool = False

    def run(self):
        try:
            super().run()
            self._logged_missing = False
        except OSError as e:
            self.output = None
            if not self._logged_missing:
                log.warning("EmacsClock: hiding: %s", e)
                self._logged_missing = True

class HomepageMusic(IntervalModule):
    interval = 5
    output = ""
    on_leftclick = "open_music"

    _port = 12099
    _url = f"http://localhost:{_port}/music"
    _repo = "/home/usr/git/homepage"
    _log = "/home/usr/.cache/homepage.log"
    _rotation = "left"  # normal, left, right or inverted

    def _is_running(self):
        try:
            with socket.create_connection(("localhost", self._port), timeout=0.5):
                return True
        except OSError:
            return False

    def _rotate(self):
        # the app rotates the screen and makes the touchscreen/pen follow;
        # its CSRF guard wants a same-origin Origin and X-Homepage: 1
        origin = f"http://localhost:{self._port}"
        request = urllib.request.Request(
            f"{origin}/api/music/rotate",
            data=urllib.parse.urlencode({"rotation": self._rotation}).encode(),
            headers={"Origin": origin, "X-Homepage": "1"},
        )
        try:
            urllib.request.urlopen(request, timeout=10).close()
        except OSError:
            pass

    def _launch(self):
        if not self._is_running():
            with open(self._log, "a") as log:
                subprocess.Popen(
                    ["nix", "develop", "-c", "python3", "-m", "homepage"],
                    cwd=self._repo,
                    stdout=log,
                    stderr=subprocess.STDOUT,
                    stdin=subprocess.DEVNULL,
                    start_new_session=True,
                )
            # nix develop can take a while; wait up to a minute for the port
            for _ in range(120):
                if self._is_running():
                    break
                time.sleep(0.5)
            else:
                return

        self._rotate()

        subprocess.Popen(
            ["brave", self._url],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )

    def open_music(self):
        # run in a thread so waiting on startup doesn't block the bar
        threading.Thread(target=self._launch, daemon=True).start()

    def run(self):
        self.output = {
            "full_text": "music",
            "color": "#ffffff" if self._is_running() else "#666666",
        }

status = Status(logfile="$HOME/.cache/i3status.log")

status.register("clock",
    format="%a%-d%b%m/%H%M%S",)

status.register(EmacsClock,
    format="{task}",
    components={
        "task": (str, ".cache/emacs-clock-status"),
    },
    base_path="/home/usr/",
    interval=2,
)

status.register(ClassMonitor)

if gethostname() == "hammurabi":
    status.register("battery",
        format="{percentage:.2f}{status}{remaining:%E%h:%M}",
        alert=True,
        alert_percentage=5,
        status={
            "DIS": "↓",
            "CHR": "↑",
            "FULL": "=",
        },)

    status.register("network",
        interface="wlp4s0",
        on_leftclick="st -c st_floating -e nmtui",
        format_up="{essid} {quality:02.0f}",
        format_down="",)

status.register(HomepageMusic)

status.register("cmus",
    format="{status} {song_elapsed}/{song_length} {title}",
    format_not_running="",)

status.run()
