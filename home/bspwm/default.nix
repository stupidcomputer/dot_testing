{ lib, config, pkgs, home, ... }:

{
  # program activation is managed by nixos config
  home.packages = with pkgs; [
    bspwm
  ];

  home.file = {
    ".config/bspwm/bspwmrc" = {
      source = ./bspwmrc;
    };
  };
}
