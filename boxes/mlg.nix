{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
    ../common/nvidia.nix
    ../common/gaming.nix
    ../common/steam.nix
  ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };

  networking.hostName = "mlg";
}
