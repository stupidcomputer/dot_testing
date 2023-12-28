{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ../../home/x11.nix
  ];

  home.stateVersion = "23.11";
}
