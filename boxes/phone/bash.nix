{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    bash
  ];

  home.file = {
    ".bashrc" = {
      source = lib.mkDefault ../../home/bash/bashrc;
    };
    ".bash_profile" = {
      source = lib.mkDefault ../../home/bash/profile;
    };
  };
}
