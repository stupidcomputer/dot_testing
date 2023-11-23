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
    libreoffice
    nomacs
    vscodium
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
