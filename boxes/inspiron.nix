{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "mainsail";
}
