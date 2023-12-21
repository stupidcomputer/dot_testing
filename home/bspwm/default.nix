{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/bspwm/bspwmrc" = {
      source = ./bspwmrc;
    };
  };
}
