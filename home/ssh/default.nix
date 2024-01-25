{ lib, config, pkgs, home, ... }:

{
  programs.ssh.enable = true;

  home.file = {
    ".ssh/config" = {
      source = ./config;
    };
  };
}
