{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".local/share/wallpapers" = {
      source = ./wallpapers;
      recursive = true;
    };
  };
}
