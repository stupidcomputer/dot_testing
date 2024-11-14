{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./services
    ../x230t/special-ssh-magic.nix
    ../../modules/ssh-phone-home.nix
    ../../modules/hosts.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
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
    kdePackages.kdenlive
    audacity
    bespokesynth
    puddletag
    musescore
    unzip
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
    git-annex
    tigervnc

    (pkgs.callPackage ../../builds/archutils.nix {})
    (pkgs.callPackage ../../builds/sssg.nix {})
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

  services = {
    # enable printing
    printing.enable = true;
    avahi = {
      enable = true; # runs the Avahi daemon
      nssmdns4 = true; # enables the mDNS NSS plug-in
      openFirewall = true; # opens the firewall for UDP port 5353
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };


  programs.adb.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "copernicus";
    firewall = {
      enable = true;
      interfaces = {
        eno1 = {
          allowedTCPPorts = [ 6000 ];
          allowedTCPPortRanges = [
            { from = 1714; to = 1764; } # KDE Connect
            { from = 10000; to = 10100; } # temp stuff
          ];
          allowedUDPPortRanges = [
            { from = 1714; to = 1764; } # KDE Connect
          ];
        };
        wg0 = {
          # allow everything bound to the wg0 interface
          allowedTCPPortRanges = [
            { from = 1; to = 35565; }
          ];
          allowedUDPPortRanges = [
            { from = 1; to = 35565; }
          ];
        };
      };
    };
  };

  programs.kdeconnect.enable = true;

  system.stateVersion = "24.05"; # don't change this, lol
}
