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

    ./x11-progs.nix
    ./tty.nix
  ];
}
