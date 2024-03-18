{ lib, config, pkgs, home, ... }:

{
  # managed by nixos configuration
  home.packages = with pkgs; [
    sxhkd
  ];

  home.file = {
    ".config/sxhkd/sxhkdrc" = {
      source = ./sxhkdrc;
    };
    ".config/sxhkd/mouse" = {
      source = ./mouse;
    };
  };
}
