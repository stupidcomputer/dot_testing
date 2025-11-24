{ pkgs, lib, machines, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./agenix.nix
    ./sshd.nix
    ./printing.nix
    ../../lib/bootstrap.nix

    # individual program configs
    ../../config/aerc
    ../../config/bash
    ../../config/brave
    ../../config/cmus
    ../../config/emacs
    ../../config/git
    ../../config/hueadm
    ../../config/i3
    ../../config/i3pystatus
    ../../config/nvim
    ../../config/productionutils
    ../../config/rbw
    ../../config/ssh
    ../../config/sx
    ../../config/termutils
    ../../config/zathura
  ];

  services.tailscale = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    syncthing
    prismlauncher

    # custom builds
    (pkgs.callPackage ../../builds/st.nix { lightMode = false; })
    (pkgs.callPackage ../../builds/dmenu.nix {})
    (pkgs.callPackage ../../builds/utils.nix {})
    (pkgs.callPackage ../../builds/statusbar {})
    (pkgs.callPackage ../../builds/sssg.nix {})

    i3-swallow
  ];

  services.ollama.enable = true;
  services.open-webui.enable = true;

  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];

  virtualisation.virtualbox.host.enable = true;
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # virtualbox doesn't like kvm

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
      wakeOnLan = {
        enable = true;
        policy = [ "magic" ];
      };
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
          allowedTCPPortRanges = [
            { from = 10000; to = 10100; } # temp stuff
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
    nameservers = [ "8.8.8.8" "8.4.4.8" ];
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
      windowManager.i3 = {
        enable = true;
      };
      enable = true;
      xkb.layout = "us";
    };
    displayManager.ly.enable = true;
    libinput.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  systemd.services.syncthing = {
    enable = true;
    description = "start syncthing on network startup";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.syncthing}/bin/syncthing";
      User = "usr";
      Restart = "on-failure";
      RestartSec = "3";
    };
  };

  system.stateVersion = "24.05"; # don't change this, lol
}
