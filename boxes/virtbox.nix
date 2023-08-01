{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "virtbox";
}
