{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    khard
  ];

  home.file = {
    ".config/khard/khard.conf" = {
      source = ../../.config/khard/khard.conf;
    };
  };
}
