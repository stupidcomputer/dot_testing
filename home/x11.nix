{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ./bspwm
    ./brave
    ./dunst
    ./sx
    ./sxhkd
    ./tridactyl
    ./zathura
    ./wallpapers
    ./vdirsyncer
    ./khal
    ./khard
    ./isync
    ./todoman
    ./neomutt
    ./msmtp
    ./rbw
    ./nws
    ./xscreensaver

    ./x11-progs.nix
    ./tty.nix
  ];
}
