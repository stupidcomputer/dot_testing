{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    msmtp
  ];

  home.file = {
    ".config/msmtp/config" = {
      source = ./config;
    };
  };
}
