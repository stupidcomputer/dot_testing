{ lib, config, pkgs, ...}:

{
  imports = [
    ../desktop.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "virtbox";
}
