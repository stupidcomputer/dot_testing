{ lib, config, pkgs, ...}:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
    sha256 = "0dfshsgj93ikfkcihf4c5z876h4dwjds998kvgv7sqbfv0z6a4bc";
  };
  customPolybar = pkgs.polybar.override {
    alsaSupport = true;
    pulseSupport = true;
  };
in {
  imports = [
    (import "${home-manager}/nixos")
    ./main.nix
  ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    layout = "us";

    displayManager.sx.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    sx
    fzy
    xclip
    xcape
    ffmpeg

    ncmpcpp
    pciutils
    xscreensaver
    ncpamixer
    gpick
    dunst
    libnotify
    tig
    neomutt
    mpv
    yt-dlp
    zathura
    tmux
    lynx
    feh
    elinks
    sc-im
    ledger
    remind
    python3
    pinentry-curses

    ungoogled-chromium
    discord

    customPolybar
    (pkgs.callPackage ../builds/utils.nix {})
    (pkgs.callPackage ../builds/st.nix {})
    (pkgs.callPackage ../builds/pash.nix {})
  ];

  fonts.fonts = with pkgs; [
    fantasque-sans-mono
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = {
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableSetDesktopBackground = true;
      DisplayBookmarksToolbar = "never";
      DontCheckDefaultBrowser = true;
      Extensions = {
        Install = [
          "https://addons.mozilla.org/firefox/downloads/file/3812704/umatrix-1.4.4.xpi"
          "https://addons.mozilla.org/firefox/downloads/file/3824639/gruvbox_true_dark-2.0.xpi"
          "https://addons.mozilla.org/firefox/downloads/file/4128489/darkreader-4.9.64.xpi"
          "https://addons.mozilla.org/firefox/downloads/file/4036604/tridactyl_vim-1.23.0.xpi"
          "https://addons.mozilla.org/firefox/downloads/file/4098688/user_agent_string_switcher-0.5.0.xpi"
        ];
      };
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
        TopSites = false;
        SponsoredTopSites = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        UrlbarInterventions = false;
        WhatsNew = false;
      };
      EnableTrackingProtection = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PasswordManagerEnabled = false;
      SearchSuggestEnabled = false;
    };
    nativeMessagingHosts.tridactyl = true;
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/usr/music";
    extraConfig = ''
      audio_output {
        type "pulse"
        name "pulseaudio"
        server "127.0.0.1"
      }
    '';
  };

  users.users.usr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "usr";
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
      ${pkgs.git}/bin/git https://git.beepboop.systems/rndusr/privdata /home/usr/git/privdata
    fi
  '';

  home-manager.users.usr.home = {
    stateVersion = "23.05";

    file = {
      ".config/bash" = {
        source = ../config/bash;
        recursive = true;
      };
      ".config/bspwm" = {
        source = ../config/bspwm;
        recursive = true;
      };
      ".config/git" = {
        source = ../config/git;
        recursive = true;
      };
      ".config/htop" = {
        source = ../config/htop;
        recursive = true;
      };
      ".config/nvim" = {
        source = ../config/nvim;
        recursive = true;
      };
      ".config/python" = {
        source = ../config/python;
        recursive = true;
      };
      ".config/polybar" = {
        source = ../config/polybar;
        recursive = true;
      };
      ".config/sx" = {
        source = ../config/sx;
        recursive = true;
      };
      ".config/sxhkd" = {
        source = ../config/sxhkd;
        recursive = true;
      };
      ".config/tridactyl" = {
        source = ../config/tridactyl;
        recursive = true;
      };
      ".config/zathura" = {
        source = ../config/zathura;
        recursive = true;
      };
      ".local/share/wallpapers" = {
        source = ../wallpapers;
        recursive = true;
      };
      ".local/share/gnupg" = {
        source = ../config/gnupg;
        recursive = true;
      };
    };
  };

  environment.etc = {
    "profile.local" = {
      text = "source /home/usr/.config/bash/profile";
    };
    "bashrc.local" = {
      text = "source /home/usr/.config/bash/bashrc";
    };
  };

  programs.ssh.askPassword = "";
}