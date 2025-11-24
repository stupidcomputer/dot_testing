{ config, pkgs, ... }:

{
  imports = [
    ./agenix.nix
    ./hardware-configuration.nix
    ../copernicus/printing.nix

    ../../config/aerc
    ../../config/bash
    ../../config/brave
    ../../config/cmus
    ../../config/emacs
    ../../config/git
    ../../config/nvim
    ../../config/rbw
    ../../config/ssh
    ../../config/syncthing

    ../../config/termutils
  ];

  environment.systemPackages = with pkgs; [
    (callPackage ../../builds/utils.nix {})
    (callPackage ../../builds/rebuild.nix {})
    (callPackage ../../builds/tilp.nix {})
    musescore
    vscodium-fhs
    kdePackages.kdenlive
    obs-studio
    gimp
    prismlauncher
    rofi-wayland
    wl-clipboard
    anki-bin
    sshuttle
    scrcpy
  ];

  programs.adb.enable = true;

  programs.steam.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hammurabi"; # Define your hostname.
  networking.networkmanager.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.usr = {
    isNormalUser = true;
    description = "Ryan Marina";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
  system.stateVersion = "25.05";
}
