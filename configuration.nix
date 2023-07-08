{ config, pkgs, ... }:

let
  hostname = "virtbox";
in
{
  imports =
    [
      ./hardware-configuration.nix # include the results of the hardware scan
      ./virtbox.nix
      ./netbox.nix
    ];

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    neovim
    curl
    htop
    git
  ];

  system.copySystemConfiguration = true;
  system.stateVersion = "23.05"; # don't change this, lol

  # branch and enable different capabilities based on the system

  lib.mkIf hostname == "virtbox" {
    services.virtbox.enable = true;
  };
}
