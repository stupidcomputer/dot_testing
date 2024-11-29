{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ./bspwm
    ./brave
    ./sx
    ./sxhkd
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
    ./xscreensaver

    ./x11-progs.nix
    ./tty.nix
  ];
}
