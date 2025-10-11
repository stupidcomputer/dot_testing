{ pkgs, lib, machines, ... }:
{
  imports = [
    ./sshd.nix
    ./agenix.nix
    ./hardware-configuration.nix
    ../copernicus/printing.nix

    ../../config/aerc
    ../../config/bash
    ../../config/brave
    ../../config/cmus
    ../../config/emacs
    ../../config/git
    ../../config/htop
    ../../config/hueadm
    ../../config/i3
    ../../config/i3pystatus
    ../../config/nvim
    ../../config/productionutils
    ../../config/python
    ../../config/rbw
    ../../config/scrcpy
    ../../config/ssh
    ../../config/sx
    ../../config/syncthing
    ../../config/termutils
    ../../config/tor-browser
    ../../config/zathura
  ];

  environment.systemPackages = with pkgs; [
    (callPackage ../../builds/st.nix {})
    (callPackage ../../builds/utils.nix {})
    (callPackage ../../builds/rebuild.nix {})
    (callPackage ../../builds/sssg.nix {})
    (callPackage ../../builds/tilp.nix {})
    appimage-run
    sage
    libreoffice
    prismlauncher
    dmenu
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = "plato";
    networkmanager.enable = true;
  };
  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.usr = {
    isNormalUser = true;
    description = "usr";
    extraGroups = [ "networkmanager" "wheel" "input" "adbusers" ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      windowManager.i3.enable = true;
    };
    displayManager.ly.enable = true;
    libinput.enable = true;
    tlp.enable = true;
  };

  powerManagement.powertop.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    corefonts
    vistafonts
    proggyfonts
  ];

  services.printing.enable = true;

  system.stateVersion = "24.05";
}
