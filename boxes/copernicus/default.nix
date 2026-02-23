{ pkgs, lib, machines, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix
    ../../common/bootstrap.nix
    ./agenix.nix
    ./sshd.nix
  ];

  services.ryande.enable = true;

  nix.settings = {
    cores = 16;
    max-jobs = 24;
  };
  nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    soundwireserver
    vscode
  ];

  virtualisation.virtualbox.host.enable = true;
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # virtualbox doesn't like kvm

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

  services.pipewire = {
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

  powerManagement.cpuFreqGovernor = "performance";

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
          allowedTCPPorts = [ 59010 2342 ];
        };
      };
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  # don't touch these
  system.stateVersion = "24.05";
  home-manager.users.usr.home.stateVersion = "25.11";
}
