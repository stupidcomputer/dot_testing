{ config, pkgs, options, ... }:

{
  imports = [
    ./agenix.nix
    ./hardware-configuration.nix
    ../copernicus/printing.nix

    ../../config/aerc
    ../../config/bash
    ../../config/brave
    ../../config/emacs
    ../../config/git
    ../../config/nvim
    ../../config/syncthing

    ../../config/termutils
  ];

  nix.settings = {
    download-buffer-size = 10000000000;
    warn-dirty = false;
  };

  environment.systemPackages = with pkgs; [
    (callPackage ../../builds/st.nix {})
    (callPackage ../../builds/dmenu.nix {})
    (callPackage ../../builds/utils.nix {})
    (callPackage ../../builds/rebuild.nix {})
    (callPackage ../../builds/tilp.nix {})
    musescore
    vscodium-fhs
    kdePackages.kdenlive
    obs-studio
    gimp
    prismlauncher
    wl-clipboard
    anki-bin
    sshuttle
    scrcpy
    i3pystatus
    i3

    xorg.xset
    xorg.setxkbmap
    xcape
    xclip
    x11vnc
    xwallpaper
    xdotool
    tigervnc

    feh
    picom
    arandr

    mpv
    sxiv
    scrcpy
  ];

  services.power-profiles-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.adb.enable = true;
  services.tailscale.enable = true;
  services.xserver = {
    windowManager.i3.enable = true;
    enable = true;
  };

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

  services.displayManager.ly.enable = true;

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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
  services.ntp.enable = true;
  system.stateVersion = "25.05";

  system.userActivationScripts.copyI3pystatusConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/i3pystatus
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/i3pystatus/config.py /home/usr/.config/i3pystatus/config.py
    '';
    deps = [];
  };
  system.userActivationScripts.copyI3wmConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/i3
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/i3/config /home/usr/.config/i3/config
    '';
    deps = [];
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

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
}
