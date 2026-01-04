{ config, lib, pkgs, options, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix
    ../../common/bootstrap.nix
    ./agenix.nix
  ];

  services.ryande.enable = true;

  environment.systemPackages = with pkgs; [
    (callPackage ../../builds/tilp.nix {})
    anki-bin
    sshuttle
  ];

  services = {
    power-profiles-daemon.enable = true;
    ntp.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv4.tcp_ecn" = 0;
    };
  };

  networking = {
    hostName = "hammurabi";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  # temporary
  time.timeZone = lib.mkForce "America/Chicago";

  # don't touch these
  system.stateVersion = "25.05";
  home-manager.users.usr.home.stateVersion = "25.05";
}
