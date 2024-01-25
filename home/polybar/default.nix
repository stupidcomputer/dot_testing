{ lib, config, pkgs, home, ... }:

{
  # activated by nixos configuration
  home.file = {
    ".config/polybar/config.ini" = {
      source = ./config.ini;
    };
  };
}
