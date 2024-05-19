{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ./bspwm
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

    ./x11-progs.nix
    ./tty.nix
  ];
}
