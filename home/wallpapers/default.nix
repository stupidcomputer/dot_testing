{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".local/share/wallpapers" = {
      source = ./src;
      recursive = true;
    };
  };
}
