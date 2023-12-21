{ lib, config, pkgs, home-manager, ...}:

let
  customPolybar = pkgs.polybar.override {
    alsaSupport = true;
    pulseSupport = true;
  };
in {
  imports = [
    home-manager.nixosModules.default
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
    permittedInsecurePackages = [
      "libxls-1.6.2"
    ];
  };

  environment.systemPackages = with pkgs; [
    sx
    fzy
    xclip
    xcape
    ffmpeg
    man-pages

    ncmpcpp
    pciutils
    tor-browser-bundle-bin
    xscreensaver
    ncpamixer
    gpick
    calcurse
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
    magic-wormhole
    xbrightness
    xdotool
    figlet
    neomutt

    unzip
    lua-language-server
    rnix-lsp
    python311Packages.jedi-language-server

    ungoogled-chromium
    discord

    customPolybar
    (pkgs.callPackage ../builds/utils.nix {})
    (pkgs.callPackage ../builds/st.nix {})
    (pkgs.callPackage ../builds/pash.nix {})
  ];

  fonts.packages = with pkgs; [
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
    nativeMessagingHosts.packages = [
      pkgs.tridactyl-native
    ];
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/usr/music";
    user = "usr";
    extraConfig = ''
      audio_output {
        type "pulse"
        name "Pulseaudio"
      }
      audio_output {
        type "alsa"
        name "mpd alsamixer-output"
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

  home-manager.nixosModules.home-manager.users.usr = {
    home.stateVersion = "23.05";

    programs.neovim = {
      enable = true;
      extraLuaPackages = luaPkgs: with luaPkgs; [ luaexpat ];
      extraPackages = [ pkgs.sqlite ];
    };

    home.file = {
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
      ".config/emacs" = {
        source = ../config/emacs;
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
