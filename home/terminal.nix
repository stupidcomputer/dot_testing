{ lib, config, pkgs, home, ... }:

{
  imports = [
    ./bash/default.nix
    ./bspwm/default.nix
  ];

  home.stateVersion = "23.11";

  programs.neovim = {
    enable = true;
  };

  home.file = {
    ".config/git" = {
      source = ../config/git;
      recursive = true;
    };
    ".config/htop" = {
      source = ../config/htop;
      recursive = true;
    };
    ".config/nvim" = {
      source = ../config/nvim;
      recursive = true;
    };
    ".config/python" = {
      source = ../config/python;
      recursive = true;
    };
    ".config/polybar" = {
      source = ../config/polybar;
      recursive = true;
    };
    ".config/sx" = {
      source = ../config/sx;
      recursive = true;
    };
    ".config/sxhkd" = {
      source = ../config/sxhkd;
      recursive = true;
    };
    ".config/tridactyl" = {
      source = ../config/tridactyl;
      recursive = true;
    };
    ".config/zathura" = {
      source = ../config/zathura;
      recursive = true;
    };
    ".local/share/wallpapers" = {
      source = ../wallpapers;
      recursive = true;
    };
    ".local/share/gnupg" = {
      source = ../config/gnupg;
      recursive = true;
    };
    ".config/emacs" = {
      source = ../config/emacs;
      recursive = true;
    };
  };
}
