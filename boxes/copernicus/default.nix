{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ../x230t/special-ssh-magic.nix
    ../../modules/ssh-phone-home.nix
    ../../modules/hosts.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/discord.nix
    ../../modules/gaming.nix
    ../../modules/rbw.nix
  ];

  virtualisation.docker.enable = true;


  users.users.usr.extraGroups = [
    "docker"
    "adbusers"
  ];

  environment.systemPackages = with pkgs; [
    wine
    xdotool

    qemu
    virt-manager
    libreoffice
    nomacs
    vscodium
    thunderbird
    libreoffice
    texliveMedium
    ledger

    unzip
    imagemagick
    pciutils
    usbutils
    pwvucontrol

    dunst
    libnotify
    ffmpeg
    mdadm

    (pkgs.callPackage ../../builds/archutils.nix {})
  ];

  services.hardware.bolt.enable = true; # thunderbolt support
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        AutoEnable = true;
        Enable = "Source,Sink,Media,Socket";
        ControllerMode = "bredr";
      };
    };
  };

  virtualisation.virtualbox.host.enable = true;

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
  services.avahi.nssmdns4 = true; # enables the mDNS NSS plug-in
  services.avahi.openFirewall = true; # opens the firewall for UDP port 5353

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.adb.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "copernicus";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 6000 ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
      ];
    };
  };

  programs.kdeconnect.enable = true;

  system.stateVersion = "24.05"; # don't change this, lol
}
