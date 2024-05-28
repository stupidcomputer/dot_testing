from multiprocessing import Process, Queue
from collections import defaultdict
from sys import argv
from sys import stdout
from math import floor
import datetime
import signal
import subprocess
import re

import os, socket, time

def find_all_belonging_to_monitor(splitted, monitor):
    splitted = [i[1:] if i[1:] == monitor else i for i in splitted]
    our_monitor = splitted.index(monitor)
    next_monitor = None
    for i in range(our_monitor, len(splitted)):
        if splitted[i][0].lower() == "m":
            next_monitor = i
            break

    if not next_monitor:
        next_monitor = len(splitted) - 1

    return splitted[our_monitor:next_monitor]

def generate_desktop_string(monitor_array):
    output = []
    for i in monitor_array:
        if i[0] == "O":
            output.append("*{}".format(i[1:]))

        if i[0] == "o":
            output.append("{}".format(i[1:]))

        if i[0] == "F":
            output.append("*{}".format(i[1:]))

    return ' '.join(output)

def filemodfactory(filename: str, modname: str):
    def filemod(queue, _):
        orig = 0
        while True:
            new = os.path.getmtime(filename)
            if(new > orig):
                with open(filename, 'r') as f:
                    queue.put({
                        "module": modname,
                        "data": f.read().rstrip()
                    })
                orig = new
            time.sleep(0.1)

    return filemod

def new_mail(queue, _):
    while True:
        dir_output = os.listdir("/home/usr/Mail/main/INBOX/new")
        dir_output = len(dir_output)
        queue.put({
            "module": "newmail",
            "data": str(dir_output)
        })
        time.sleep(20)

def bspwm(queue, monitor):
    client = socket.socket(
        socket.AF_UNIX,
        socket.SOCK_STREAM
    )
    client.connect("/tmp/bspwm_1_0-socket")

    message = "subscribe\0".encode()
    client.send(message)
    while True:
        resp = client.recv(1024).decode().rstrip()
        splitted = resp[1:].split(":")
        if not monitor == "all":
            monitor_array = find_all_belonging_to_monitor(splitted, monitor)
        else:
            monitor_array = splitted
        queue.put({
            "module": "bspwm",
            "data": generate_desktop_string(monitor_array)
        })

    client.close()

def clock(queue, _):
    while True:
        queue.put({
            "module": "clock",
            "data": datetime.datetime.now().strftime("%d/%m | %H:%M")
        })

        time.sleep(60)

def filecheckerfactory(filename: str, modname: str, timeout=60):
    def filechecker(queue, _):
        while True:
            try:
                file = open(filename)
                buf = file.read(128).rstrip()
                queue.put({
                    "module": modname,
                    "data": buf
                })

            except FileNotFoundError:
                pass

            time.sleep(timeout)

    return filechecker

battery = filecheckerfactory("/sys/class/power_supply/BAT0/capacity", "bat")
batterystatus = filecheckerfactory("/sys/class/power_supply/BAT0/status", "batstat")
sxhkdmode = filemodfactory("/home/usr/.cache/statusbar/sxhkd_mode", "sxhkdmode")

def render(modules) -> str:
    columns, _ = os.get_terminal_size(0)

    left = "{} | {}({})".format(modules["clock"], modules["bspwm"], modules["sxhkdmode"])
    right = "{} {}({})".format(modules["newmail"], modules["bat"], modules["batstat"])
    padding = " " * (columns - len(left) - len(right) - 0)

    output = left + padding + right

    # special battery trickery
    try:
        batt_percentage = int(modules["bat"]) / 100
    except ValueError:
        batt_percentage = 1

    highlighted = floor(columns * batt_percentage)

    output = "\033[?25l\033[2J\033[H\033[4m" + \
        output[:highlighted] + \
        "\033[24m" + \
        output[highlighted:]

    print(output, end='')
    stdout.flush()

def main():
    os.mkdir("/home/usr/.cache/statusbar")

    if argv[1] == "start_statusbars":
        # get the monitors
        xrandr = subprocess.Popen(['xrandr'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = list(xrandr.stdout)
        output = [i.decode("utf-8") for i in output if " connected" in i.decode("utf-8")]
        serialized = []
        for i in output:
            splitted = i.split(' ')
            print(splitted)
            displayname = splitted[0]
            geometry = splitted[2]
            if geometry == "primary":
                geometry = splitted[3]

            try:
                geometry_splitted = [int(i) for i in geometry.replace('x', '+').split('+')]
            except ValueError:
                continue
            geometry_splitted[1] = 20
            print(displayname, geometry_splitted)
            os.system("st -c statusbar -p -g {}x{}+{}+{} -e statusbar {} & disown".format(
                *map(str, geometry_splitted),
                displayname
            ))
        return
    queue = Queue()
    modules = [bspwm, clock, battery, batterystatus, sxhkdmode, new_mail]
    [Process(target=module, args=(queue, argv[1])).start() for module in modules]

    module_outputs = defaultdict(lambda: "")

    while True:
        result = queue.get()
        module_outputs[result["module"]] = result["data"]
        render(module_outputs)

if __name__ == "__main__":
    main()
