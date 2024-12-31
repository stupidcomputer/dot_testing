{ pkgs, lib, machines, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./services
    ../../config/copernicus.nix
    ../../lib/bootstrap.nix
  ];

  environment.systemPackages = with pkgs; [
    wine
    xdotool

    libreoffice
    texliveMedium
    kdePackages.kdenlive
    audacity
    bespokesynth
    musescore
    unzip
    ledger

    unzip
    imagemagick
    pciutils
    usbutils

    ffmpeg
    mdadm
    git-annex
    tigervnc

    dmenu

    (pkgs.callPackage ../../builds/archutils.nix {})
    (pkgs.callPackage ../../builds/sssg.nix {})
  ];

  services.hardware.bolt.enable = true; # thunderbolt support
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
#        AutoEnable = true;
        Enable = "Source,Sink,Media,Socket";
#        ControllerMode = "bredr";
      };
    };
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
      extraConfig.pipewire = {
        "properties" = {
          default.clock.allowed-rates = [ 44100 48000 96000 ];
          "log.level" = 4;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 256;
        };
      };
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
    interfaces.eno1 = {
      useDHCP = true;
      ipv4.addresses = [
        {
          address = "192.168.1.201";
          prefixLength = 24;
        }
      ];
    };
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
    hosts = lib.attrsets.mergeAttrsList [
      (machines.mkHosts machines "aristotle" "localnet")
      (machines.mkHosts machines "router" "localnet")
      (machines.mkHosts machines "phone" "localnet")
      (machines.mkHosts machines "netbox" "internet")
    ];
  };

  services.getty.autologinUser = "usr";

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.usr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "adbusers" ];
    initialPassword = "usr";
  };

  system.stateVersion = "24.05"; # don't change this, lol
}
