{ config, pkgs, lib, ... }:

{
  home.username = "usr";
  home.homeDirectory = lib.mkForce "/home/usr";

  home.packages = [
    pkgs.htop
  ];
  programs.neovim = {
    enable = true;
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
