{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    isync
  ];

  home.file = {
    ".config/isync/config" = {
      source = ../../.config/isync/config;
    };
  };
}
