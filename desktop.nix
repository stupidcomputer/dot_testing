{ lib, config, pkgs, ...}:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
    sha256 = "0dfshsgj93ikfkcihf4c5z876h4dwjds998kvgv7sqbfv0z6a4bc";
  };
in {
  imports = [
    (import "${home-manager}/nixos")
    ./configuration.nix
  ];

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

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    sx
    fzy
    gnupg
    xclip
    polybar

    ncpamixer
    tig
    cmus
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

    discord

    (pkgs.callPackage ./builds/utils.nix {})
    (pkgs.callPackage ./builds/st.nix {})
    (pkgs.callPackage ./builds/pash.nix {})
  ];

  fonts.fonts = with pkgs; [
    fantasque-sans-mono
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
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
      ${pkgs.git}/bin/git https://git.beepboop.systems/rndusr/privdata /home/usr/git/privdata
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
      ".config/polybar" = {
        source = ./config/polybar;
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

  environment.etc = {
    "profile.local" = {
      text = "source $HOME/.config/bash/profile";
    };
  };
}
