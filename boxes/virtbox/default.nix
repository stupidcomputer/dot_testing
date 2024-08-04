{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/bootstrap.nix
    ../../modules/hosts.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/pulse.nix
    ../../modules/discord.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "virtbox";

  system.stateVersion = "23.11";
}
