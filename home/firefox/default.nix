{ lib, config, pkgs, home, inputs, ... }:

{
  imports = [inputs.schizofox.homeManagerModule];
  programs.schizofox = {
    enable = true;

    theme = {
      simplefox.enable = true;
      darkreader.enable = true;
    };
  };
}
