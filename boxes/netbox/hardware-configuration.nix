{ lib, ... }:
{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a57b82ca-7bfd-458e-b3e8-4962511cc0b8";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/DF39-1ECE";
      fsType = "vfat";
    };
    "/annex" = {
      device = "/dev/disk/by-uuid/02003f0b-a1e9-470c-bd38-99c5b1923203";
      fsType = "ext4";
    };
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/57fbd850-1ced-4e21-9e52-4f3b529c61b0"; }
    { device = "/annex/swap2"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.hypervGuest.enable = true;
}
