{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ./bspwm
    ./polybar
    ./sx
    ./sxhkd
    ./tridactyl
    ./zathura
    ./wallpapers
    ./firefox
    ./emacs
    ./vdirsyncer
    ./khal
    ./isync
    ./todoman
    ./neomutt

    ./x11-progs.nix
    ./tty.nix
  ];
}
