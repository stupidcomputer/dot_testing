{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/pulse.nix
    ../../modules/hosts.nix
    ../../modules/tlp.nix
    ../../modules/media.nix
    ../../modules/anki.nix
    ../../modules/power-control.nix
    ../../modules/adb.nix
    ../../modules/rbw.nix
  ];

  environment.systemPackages = with pkgs; [
    xscreensaver
    texliveFull
    libreoffice

    ecryptfs
    ffmpeg
    thunderbird
    ledger
    ranger
  ];

  hardware.bluetooth = {
    enable = true;
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  users.users.usr.extraGroups = [ "input" ];

  services.getty.autologinUser = "usr";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.pulseaudio.enable = true;

  networking.hostName = "aristotle";

  system.stateVersion = "24.05";
}
