{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xps";
}
