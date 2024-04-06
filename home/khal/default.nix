{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    khal
  ];

  home.file = {
    ".config/khal/config" = {
      source = ../../.config/khal/config;
    };
  };
}
