{ pkgs, lib, machines, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ../../ryande.nix
    ./nvidia.nix
    ./agenix.nix
    ./sshd.nix
    ./printing.nix
    ../../lib/bootstrap.nix
  ];

  services.ryande.enable = true;

  nix.settings = {
    cores = 16;
    max-jobs = 24;
    download-buffer-size = 10000000000;
    warn-dirty = false;
  };

  environment.systemPackages = with pkgs; [
    soundwireserver
  ];

  nixpkgs.config.cudaSupport = true;

  virtualisation.virtualbox.host.enable = true;
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # virtualbox doesn't like kvm

  services.hardware.bolt.enable = true; # thunderbolt support
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
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
          allowedUDPPorts = [ 59010 ];
          allowedTCPPorts = [ 59010 ];
        };
      };
    };
    nameservers = [ "8.8.8.8" "8.4.4.8" ];
  };

  time.timeZone = "America/Chicago";

  system.stateVersion = "24.05"; # don't change this, lol
  home-manager.users.usr.home.stateVersion = "25.11";
}
