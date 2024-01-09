{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/tlp.nix
  ];

  hardware.pulseaudio.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "x230t";

  system.stateVersion = "23.11";
}