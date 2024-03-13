{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ./bspwm
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
    ./msmtp
    ./rbw

    ./x11-progs.nix
    ./tty.nix
  ];
}
