{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/bash/bashrc" = {
      source = ./bashrc;
    };
    ".config/bash/profile" = {
      source = ./profile;
    };
  };
}
