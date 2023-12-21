{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/python/pythonrc" = {
      source = ./pythonrc.py;
    };
  };
}
