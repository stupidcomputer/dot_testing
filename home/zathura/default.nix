{ lib, config, pkgs, home, ... }:

{
  programs.zathura = {
    enable = true;
    extraConfig = (builtins.readFile ./zathurarc);
  };
}
