{ lib, config, pkgs, home, ... }:

{
  programs.htop.enable = true;

  home.file = {
    ".config/htop/htoprc" = {
      source = ../../.config/htop/htoprc;
    };
  };
}
