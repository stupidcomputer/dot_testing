{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/khal/config" = {
      source = ./config;
    };
  };
}
