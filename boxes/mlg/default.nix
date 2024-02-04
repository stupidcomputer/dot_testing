{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ../../modules/ssh-phone-home.nix
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
    deepin.deepin-album
    libreoffice
    nomacs
    vscodium
    thunderbird
    kitty
  ];

  services.hardware.bolt.enable = true;

  services.openssh.enable = true;
  services.ssh-phone-home = {
    enable = true;
    localUser = "usr";
    remoteHostname = "192.168.1.100";
    remotePort = 22;
    remoteUser = "usr";
    bindPort = 2222;
  };

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

  services.printing.enable = true;
  services.avahi.enable = true; # runs the Avahi daemon
  services.avahi.nssmdns = true; # enables the mDNS NSS plug-in
  services.avahi.openFirewall = true; # opens the firewall for UDP port 5353

  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "mlg";
    firewall.enable = true;
  };
}
