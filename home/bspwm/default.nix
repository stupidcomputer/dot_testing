{ lib, config, pkgs, home, ... }:

{
  # program activation is managed by nixos config

  home.file = {
    ".config/bspwm/bspwmrc" = {
      source = ./bspwmrc;
    };
  };
}
