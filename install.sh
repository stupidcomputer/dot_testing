#!/bin/sh

set -x

# check that $XDG_CONFIG_HOME has been assigned
[ -z "$XDG_CONFIG_HOME" ] && XDG_CONFIG_HOME="$HOME/.config"

for i in bspwm nvim sx sxhkd vimb zathura; do
  # copy everthing to the config directory
  cp -r "$i" $XDG_CONFIG_HOME
done
