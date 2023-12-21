{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];
  
  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
