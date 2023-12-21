{ lib, config, pkgs, home, ... }:

{
  imports = [
    ./bash/default.nix
    ./bspwm/default.nix
    ./git/default.nix
    ./htop/default.nix
    ./nvim/default.nix
    ./python/default.nix
    ./polybar/default.nix
    ./sx/default.nix
    ./sxhkd/default.nix
    ./tridactyl/default.nix
    ./zathura/default.nix
    ./wallpapers/default.nix
    ./firefox/default.nix
    ./gnupg/default.nix
    ./emacs/default.nix
  ];

  home.stateVersion = "23.11";
}
