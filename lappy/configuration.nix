{ config, pkgs, ... }:

{
  imports = [
    ./builds
    ./config
    ./paperless.nix
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
  };

  networking = {
    hostName = "aristotle";
    networkmanager.enable = true;
  };
  hardware = {
    pulseaudio.enable = true;
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "bredr";
    };
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.usr = {
    isNormalUser = true;
    description = "usr";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git

    brave
    (pkgs.st.overrideAttrs (old: {
        patches = [
          ./builds/st/scrollback.patch
          ./builds/st/clipboard.patch
        ];
        conf = ./builds/st/config.h;
      })
    )
    dmenu
    cmus
    htop
    rbw
    pinentry-tty
    ncpamixer
    bluetuith
  ];

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    libinput.enable = true;
    tlp.enable = true;
  };

  system.stateVersion = "24.05";
}
