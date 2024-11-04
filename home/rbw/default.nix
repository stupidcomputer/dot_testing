{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    rbw
  ];

  home.file = {
    ".config/rbw/config.json" = {
      source = ../../.config/rbw/config.json;
    };
  };
}
