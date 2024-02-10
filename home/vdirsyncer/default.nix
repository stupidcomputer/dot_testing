{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/vdirsyncer/config" = {
      source = ./config;
    };
  };
}
