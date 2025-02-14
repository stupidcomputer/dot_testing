setxkbmap -option caps:super
pkill xcape
xcape -e 'Super_L=Escape'
xkbset bo 50
xkbset exp =bo
xset -q | grep "Caps Lock:\s*on" && xdotool key Caps_Lock
xset -r 161 # tablet rotate key doesn't need repeat
xset r rate 300 80
