{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/discord.nix
    ../../modules/gaming.nix
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
    libreoffice
    nomacs
    vscodium
    thunderbird
    minetest
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

  services.printing.enable = true;
  services.avahi.enable = true; # runs the Avahi daemon
  services.avahi.nssmdns = true; # enables the mDNS NSS plug-in
  services.avahi.openFirewall = true; # opens the firewall for UDP port 5353

  networking.hostName = "mlg";
}
