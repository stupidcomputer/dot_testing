{ pkgs, lib, machines, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./agenix.nix
    ./config.nix
    ./sshd.nix
    ../../lib/bootstrap.nix
  ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;

  environment.systemPackages = with pkgs; [
    wine
    xdotool

    libreoffice
    texliveFull
    kdePackages.kdenlive
    audacity
    bespokesynth
    musescore
    unzip
    ledger
    scrcpy
    inotify-tools
    thunderbird
    libsForQt5.kaccounts-integration
    libsForQt5.kaccounts-providers
    libsForQt5.krunner
    libsForQt5.kalarm
    redshift
    davinci-resolve
    gimp
    inkscape
    steam
    zoom-us
    tor-browser
    kdenlive
    kdePackages.partitionmanager
    cryptsetup
    age

    unzip
    imagemagick
    pciutils
    usbutils
    kdePackages.kmail
    kdePackages.kgpg
    emacs

    ffmpeg
    mdadm
    git-annex
    tigervnc
    i3

    dmenu

    (pkgs.callPackage ../../builds/sssg.nix {})
  ];

  virtualisation.virtualbox.host.enable = true;

  programs.kdeconnect.enable = true;
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

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.usr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "adbusers" "wireshark" ];
    initialPassword = "usr";
  };

  services = {
    xserver = {
      displayManager.sx.addAsSession = true;
      desktopManager.plasma5.enable = true;
    };
    displayManager.sddm.enable = true;
  };

  system.stateVersion = "24.05"; # don't change this, lol
}
