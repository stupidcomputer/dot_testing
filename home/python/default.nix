{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/python/pythonrc" = {
      source = ../../.config/python/pythonrc.py;
    };
  };
}
