{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
    ../common/nvidia.nix
    ../common/gaming.nix
    ../common/steam.nix
  ];

  environment.systemPackages = with pkgs; [
    wine
    xdotool

    qemu
    virt-manager
    gnome.cheese
    calyx-vpn
    android-studio
    emacs
    deepin.deepin-album
    nomacs
    vscodium
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

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  users.users.usr.extraGroups = [ "libvirtd" ];

  networking.hostName = "mlg";
}
