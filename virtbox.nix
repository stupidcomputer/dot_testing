{ lib, config, pkgs, ...}:

let
  cfg = config.services.virtbox;
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
    sha256 = "0dfshsgj93ikfkcihf4c5z876h4dwjds998kvgv7sqbfv0z6a4bc";
  };
in {
  options.services.virtbox = {
    enable = lib.mkEnableOption "virtbox configs";
  };

  imports = [
    (import "${home-manager}/nixos")
  ];

  config = lib.mkIf cfg.enable {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";

    networking.hostName = "virtbox";

    services.xserver = {
      enable = true;
      libinput.enable = true;
      layout = "us";

      # we're going to be pulling a sneaky
      # we don't actually use startx, it just gets lightdm out of the way
      displayManager.startx.enable = true;
    };

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    environment.systemPackages = with pkgs; [
      sx

      (pkgs.callPackage ./builds/utils.nix {})
    ];

    users.users.usr = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
        firefox
        tree
        bspwm
        sxhkd
      ];
    };


    # honking impure, but who's counting anyway?
    system.activationScripts.test-script.text = ''
      #!${pkgs.bash}/bin/bash

      if [ "$(${pkgs.coreutils}/bin/whoami)" = "usr"]; then
        ${pkgs.coreutils}/bin/mkdir -p /home/usr/git
        ${pkgs.git}/bin/git https://git.beepboop.systems/rndusr/dot /home/usr/git/dot
      fi
    '';

    home-manager.users.usr.home = {
      stateVersion = "23.05";

      file = {
        ".config/bash" = {
          source = ./config/bash;
          recursive = true;
        };
        ".config/bspwm" = {
          source = ./config/bspwm;
          recursive = true;
        };
        ".config/git" = {
          source = ./config/git;
          recursive = true;
        };
        ".config/htop" = {
          source = ./config/htop;
          recursive = true;
        };
        ".config/nvim" = {
          source = ./config/nvim;
          recursive = true;
        };
        ".config/python" = {
          source = ./config/python;
          recursive = true;
        };
        ".config/sx" = {
          source = ./config/sx;
          recursive = true;
        };
        ".config/sxhkd" = {
          source = ./config/sxhkd;
          recursive = true;
        };
        ".config/tridactyl" = {
          source = ./config/tridactyl;
          recursive = true;
        };
        ".config/zathura" = {
          source = ./config/zathura;
          recursive = true;
        };
        ".local/share/wallpapers" = {
          source = ./wallpapers;
          recursive = true;
        };
      };
    };
  };
}
