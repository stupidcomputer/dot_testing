{ lib, config, pkgs, home, ... }:

{
  # activation managed by nixos config

  home.file = {
    ".config/git/config" = {
      source = ../../.config/git/config;
    };
  };
}
