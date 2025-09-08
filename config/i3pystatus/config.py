from i3pystatus import IntervalModule, Status
from dataclasses import dataclass
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
            new_item = item.replace(f" :{self._schedule_tag}:", "")
            new_item = new_item.lstrip().rstrip()
            splitted[index] = new_item
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
            elif not now in line:
                continue

            line = line.rstrip()
            relevant_lines.append(line)

        schedule_items = []
        for line in relevant_lines:
            self._schedule_items.append(self._parse_schedule_line(line))

    def _calculate_schedule_states(self, now):
        return [i.get_state(now) for i in self._schedule_items]

    def run(self):
        if self._first_run:
            self._generate_schedule_specification()
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

status = Status(logfile="$HOME/.cache/i3status.log")

status.register("text",
    text="ᛒ",
    on_leftclick="st -c st_floating -e bluetuith")

status.register("text",
    text="🎵",
    on_leftclick="st -e cmus",
    on_rightclick="st -c desktop10 -e bash -c 'CMUS_SOCKET=/run/user/1000/cmus2-socket cmus'")

status.register("text",
    text="🎛️",
    on_leftclick="st -c st_floating -e ncpamixer")

status.register("text",
    text="🪟",
    on_leftclick="arandr")

status.register("text",
    text="✇",
    on_leftclick="hueadm group 83 on",
    on_rightclick="hueadm group 83 off")

status.register("text",
    text="🔆",
    on_leftclick="hueadm group 14 on",
    on_rightclick="hueadm group 14 off")

status.register("clock",
    format="%a %-d%b (%m) %X",)

status.register(ClassMonitor)

status.register("battery",
    format="{status}{percentage:.2f}%{remaining:%E%h:%M}",
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


status.register("cmus",
    format="{status} {song_elapsed}/{song_length} {title}",
    format_not_running="",)

status.run()
