{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/python/pythonrc.py" = {
      source = ../../.config/python/pythonrc.py;
    };
  };
}
