{ lib, config, pkgs, ...}:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "virtbox";

  system.stateVersion = "23.11";
}
