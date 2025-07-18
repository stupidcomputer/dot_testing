from i3pystatus import Status
from socket import gethostname

def config_aristotle(status):
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
        format="%a %-d %b (%m) %X",)

    status.register("pomodoro",
        inactive_format="tomato",
        format="{current_pomodoro}/{total_pomodoro} {time}",)

    status.register("battery",
        format="{status} {consumption:.2f}W {percentage:.2f}% {remaining:%E%h:%M}",
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
        format_up="{essid} {quality:03.0f}%",)

    status.register("cmus",
        format="{status} {song_elapsed}/{song_length} {title}",
        format_not_running="",)

def config_copernicus(status):
    status.register("text",
        text="ᛒ",
        on_leftclick="st -c st_floating -e bluetuith")

    status.register("text",
        text="🎵",
        on_leftclick="st -e cmus")

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
        format="%a %-d %b (%m) %X",)

    status.register("pomodoro",
        inactive_format="tomato",
        format="{current_pomodoro}/{total_pomodoro} {time}",)

    status.register("cmus",
        format="{status} {song_elapsed}/{song_length} {title}",
        format_not_running="",)

hosts = {
    "aristotle": config_aristotle,
    "copernicus": config_copernicus
}

status = Status(logfile="$HOME/.cache/i3status.log")
hosts[gethostname()](status)
status.run()
