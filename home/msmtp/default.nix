{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/msmtp/config" = {
      source = ./config;
    };
  };
}
