{ pkgs, ppkgs, inputs, unstable, lib, machines, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix
    ../../common/bootstrap.nix
    ../../common/tailscale.nix
    ./agenix.nix
    ./sshd.nix
#    ./sunshine.nix
  ];

  services.ryande.enable = true;

  programs.nix-ld.enable = true;

  nix.settings = {
    cores = 16;
    max-jobs = 24;
  };
#  nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    moonlight-qt
    ddcutil
    audio-sharing
    rclone
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.package = unstable.virtualbox;
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

  # keep running with the lid closed
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [ "1.0.0.1" ];
  };

  networking = {
    hostName = "kant";
    networkmanager.enable = true;
  };

  # don't touch these
  system.stateVersion = "24.05";
  home-manager.users.usr.home.stateVersion = "25.11";
}
