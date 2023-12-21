{ lib, config, pkgs, home, ... }:

{
  # managed by nixos configuration

  home.file = {
    ".config/sxhkd/sxhkdrc" = {
      source = ./sxhkdrc;
    };
  };
}
