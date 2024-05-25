{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    khard
  ];

  home.file = {
    ".config/khard/config" = {
      source = ../../.config/khard/khard.conf;
    };
  };
}
