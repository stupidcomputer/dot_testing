{ lib, config, pkgs, home, ... }:

{
  # managed by nixos configuration

  home.file = {
    ".config/sx/sxrc" = {
      source = ./sxrc;
    };
  };
}
