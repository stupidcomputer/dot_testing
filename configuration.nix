{ lib, config, pkgs, ... }:

let
  hostname = "virtbox";
  isVirtbox = hostname == "virtbox";
  isNetbox = hostname == "netbox";
in
{
  imports =
    [
      ./hardware-configuration.nix # include the results of the hardware scan
      ./virtbox.nix
      ./netbox.nix
    ];

  networking.networkmanager.enable = true;

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
    tree
    dig
    htop
  ];

  system.copySystemConfiguration = true;
  system.stateVersion = "23.05"; # don't change this, lol

  # branch and enable different capabilities based on the system
  test = lib.mkIf isVirtbox {
    services.virtbox.enable = true;
  };

  test = lib.mkIf isNetbox {
    services.netbox.enable = true;
  };
}
