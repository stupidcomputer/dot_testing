{ config, pkgs, options, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix

    ./agenix.nix
    ../copernicus/printing.nix
  ];

  services.ryande.enable = true;

  nix.settings = {
    download-buffer-size = 10000000000;
    warn-dirty = false;
  };

  environment.systemPackages = with pkgs; [
    (callPackage ../../builds/tilp.nix {})
    anki-bin
    sshuttle
  ];

  services.power-profiles-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/Chicago";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = {
    "net.ipv4.tcp_ecn" = 0;
  };

  networking.hostName = "hammurabi"; # Define your hostname.
  networking.networkmanager.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  services.printing.enable = true;

  users.users.usr = {
    isNormalUser = true;
    description = "Ryan Marina";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
  services.ntp.enable = true;

  system.stateVersion = "25.05";
  home-manager.users.usr.home.stateVersion = "25.05";
}
