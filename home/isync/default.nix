{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/isync/config" = {
      source = ./config;
    };
  };
}
