{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    vdirsyncer
  ];

  home.file = {
    ".config/vdirsyncer/config" = {
      source = ../../.config/vdirsyncer/config;
    };
  };
}
