{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    todoman
  ];

  home.file = {
    ".config/todoman/config.py" = {
      source = ../../.config/todoman/config.py;
    };
  };
}
