{ config, lib, pkgs, ... }:
let
  cfg = config.services.ryande;
in {
  imports = [];

  options.services.ryande = {
    enable = lib.mkEnableOption "ryande";
    username = lib.mkOption {
      default = "usr";
      description = "Change the username for the user";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (callPackage ../builds/st.nix {})
      (callPackage ../builds/dmenu.nix {})
      (callPackage ../builds/utils.nix {})
      (callPackage ../builds/rebuild.nix {})
      anki-bin
      scrcpy
    ];
    nix.settings.download-buffer-size = 10000000000;

    fonts.packages = with pkgs; [
      corefonts
      dina-font
      fantasque-sans-mono
      fira-code
      fira-code-symbols liberation_ttf
      mplus-outline-fonts.githubRelease
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      proggyfonts
      vista-fonts
    ];

    # this is required for home-manager to share window managers to ly
    environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

    # enable syncthing
    systemd.services.syncthing = {
      enable = true;
      description = "start syncthing on network startup";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.syncthing}/bin/syncthing";
        User = cfg.username;
        Restart = "on-failure";
        RestartSec = "3";
      };
    };

    security.rtkit.enable = true;
    programs.adb.enable = true;
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      tailscale.enable = true;

      # configure printing
      printing.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      # xorg/graphical environment
      displayManager.ly.enable = true;
      xserver = {
        windowManager.i3.enable = true;
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };
      };
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
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
    };
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };
    time.timeZone = "America/Chicago";

    environment.etc = {
      "profile.local" = {
        text = "source /home/${cfg.username}/.config/bash/profile";
      };
      "bashrc.local" = {
        text = "source /home/${cfg.username}/.config/bash/bashrc";
      };
    };

    age = {
      secrets = {
        aerc-account-config = {
          file = ../secrets/aerc-account-config.age;
          mode = "600";
          owner = cfg.username;
          group = "users";
        };
      };
    };

    system.userActivationScripts.copyAercConfiguration = {
      text = ''
        mkdir -p /home/${cfg.username}/.config/aerc
        ${pkgs.coreutils}/bin/ln -sf ${config.age.secrets.aerc-account-config.path} /home/${cfg.username}/.config/aerc/accounts.conf
      '';
    };

    users.users."${cfg.username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "adbusers" "wireshark" "audio" ];
      initialPassword = "usr";
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    home-manager.users."${cfg.username}" = {
      imports = [
        ./i3pystatus.nix
      ];
      home.username = cfg.username;
      home.homeDirectory = "/home/${cfg.username}";

      home.packages = with pkgs; [
        # media manipulation
        musescore
        kdePackages.kdenlive
        gimp

        # minecraft
        prismlauncher

        # xorg utilities
        xorg.xset
        xorg.setxkbmap
        xcape
        xclip
        x11vnc
        xwallpaper
        xdotool
        tigervnc
        i3-swallow
        arandr
        warpd

        # other stuff
        ncpamixer
        bluetuith
        kid3-cli
        hledger
        hledger-web
        hledger-ui

        # terminal utilities
        age
        cryptsetup
        curl
        dig
        dmidecode
        ffmpeg
        fzy
        htop
        imagemagick
        jq
        kjv
        man-pages
        mdadm
        nmap
        openhue-cli
        pciutils
        peaclock
        poppler-utils
        python3
        qpdf
        ranger
        rsync
        tmux
        tree
        unzip
        usbutils
        yt-dlp
        ical2orgpy
        texliveFull
      ];

      fonts.fontconfig = {
        enable = true;
        antialiasing = true;
      };

      services.picom.enable = true;
      services.redshift = {
        enable = true;
        latitude = 35.9;
        longitude = -86.9;
        temperature.day = 6500;
        temperature.night = 2800;
      };
      programs.mpv.enable = true;
      programs.feh.enable = true;

      programs.i3pystatus = {
        enable = true;
        configuration = builtins.readFile ../config/i3pystatus/config.py;
      };
      xdg.configFile."i3/config".text = builtins.readFile ../config/i3/config;

      programs.htop.enable = true;
      programs.emacs = {
        enable = true;
        extraPackages = epkgs: with epkgs; [
          auctex
          company
          elfeed
          evil
          evil-collection
          gruvbox-theme
          htmlize
          ledger-mode
          lsp-mode
          lsp-ui
          nix-mode
          org-drill
          org-evil
          org-journal
          pdf-tools
          python-mode
          vterm
        ] ++ [
          # org support packages
          pkgs.ghostscript
          pkgs.gnuplot

          # lsp
          pkgs.lua-language-server
          pkgs.nixd
          pkgs.texlab
          pkgs.python313Packages.python-lsp-server
        ];
      };
      home.file.".emacs.d/init.el".source =  ../config/emacs/init.el;
      home.file.".emacs.d/early-init.el".source =  ../config/emacs/early-init.el;

      programs.rbw = {
        enable = true;
        settings = {
          base_url = "https://bitwarden.beepboop.systems";
          email = "bit@beepboop.systems";
          pinentry = pkgs.pinentry-curses;
        };
      };

      programs.cmus = {
        enable = true;
        extraConfig = ''
set show_current_bitrate=true
set pause_on_output_change=true
set status_display_program=cmus-status-update
        '';
      };

      programs.bash.enable = true;
      xdg.configFile = {
        "bash/bashrc".text = builtins.readFile ../config/bash/bashrc;
        "bash/profile".text = builtins.readFile ../config/bash/profile;
      };

      programs.chromium = {
        enable = true;
        package = pkgs.brave;
      };

      programs.git.enable = true;
      xdg.configFile."git/config".text = builtins.readFile ../config/git/config;

      programs.neovim = {
        enable = true;
        extraLuaConfig = builtins.readFile ../config/nvim/init.lua;
        extraPackages = with pkgs; [
          lua-language-server
          texlab
          python313Packages.python-lsp-server
          nixd
        ];
      };
      home.file.".config/nvim/colors" = {
        source = ../config/nvim/colors;
        recursive = true;
      };

      programs.aerc = {
        enable = true;
        extraConfig = builtins.readFile ../config/aerc/aerc.conf;
        extraBinds = builtins.readFile ../config/aerc/binds.conf;
      };

      programs.zathura = {
        enable = true;
        extraConfig = builtins.readFile ../config/zathura/zathurarc;
      };

      home.file.".config/python/pythonrc.py".text = builtins.readFile ../config/python/pythonrc.py;
    };
  };
}
