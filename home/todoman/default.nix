{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/todoman/config.py" = {
      source = ./config.py;
    };
  };
}
