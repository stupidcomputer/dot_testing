{ pkgs, ppkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix
    ../../common/bootstrap.nix
  ];

  virtualisation.virtualbox.guest.enable = true;
  services.ryande.enable = true;

  networking = {
    hostName = "descartes";
    networkmanager.enable = true;
    firewall.checkReversePath = false;
  };

  # don't touch these
  system.stateVersion = "25.05";
  home-manager.users.usr.home.stateVersion = "25.05";
}
