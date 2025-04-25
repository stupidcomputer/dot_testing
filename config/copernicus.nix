{ pkgs, ... }:
{
  # this is the default x11 configuration
  environment.etc = {
    "profile.local" = {
      text = "source /home/usr/.config/bash/profile";
    };
    "bashrc.local" = {
      text = "source /home/usr/.config/bash/bashrc";
    };
  };

  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";

      displayManager.sx.enable = true;
    };
    libinput.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    bspwm
    cmus
    git
    isync
    khal
    khard
    msmtp
    neomutt
    neovim
    qutebrowser
    rbw pinentry # needed for rbw
    sx
    sxhkd
    todoman
    vdirsyncer
    xscreensaver
    zathura
    anki

    # misc x11 progs
    xclip
    xcape
    mpv
    sxiv
    xwallpaper
    xbrightness
    xdotool
    xscreensaver
    ffmpeg # not x11 but close enough
    tigervnc
    brave
    mdadm
    veracrypt
    syncthing
    emacsPackages.pdf-tools

    # misc tty progs
    tmux
    tree
    python3
    ncpamixer # audio mixer
    bluetuith # bluetooth
    kid3-cli
    peaclock
    yt-dlp
    curl
    tree
    dig
    pciutils
    usbutils
    rsync
    man-pages
    fzy
    x11vnc
    dig

    # for neovim support
    lua-language-server
    python311Packages.python-lsp-server
    texlab
    nixd

    # custom builds
    (pkgs.callPackage ../builds/st.nix { lightMode = false; })
    (pkgs.callPackage ../builds/dmenu.nix {})
    (pkgs.callPackage ../builds/utils.nix {})
    (pkgs.callPackage ../builds/statusbar {})
  ];

  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];

  systemd.services.syncthing = {
    enable = true;
    description = "start syncthing on network startup";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.syncthing}/bin/syncthing";
      User = "usr";
      Restart = "on-failure";
      RestartSec = "3";
    };
  };

  system.userActivationScripts = {
    copyConfiguration = {
      text = ''
        if [ -d /home/usr/dots ]; then
          config_prefix="/home/usr/dots/config"
        else
          config_prefix="/home/usr/dot_testing/config"
        fi

        mkdir -p /home/usr/.config/bash
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/bash/bashrc /home/usr/.config/bash/bashrc
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/bash/profile /home/usr/.config/bash/profile

        mkdir -p /home/usr/.config/bspwm
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/bspwm/bspwmrc /home/usr/.config/bspwm/bspwmrc

        mkdir -p /home/usr/.config/cmus
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/cmus/rc /home/usr/.config/cmus/rc

        mkdir -p /home/usr/.emacs.d
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/emacs/init.el /home/usr/.emacs.d/init.el

        mkdir -p /home/usr/.config/git
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/git/config /home/usr/.config/git/config

        mkdir -p /home/usr/.config/isync
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/isync/config /home/usr/.config/isync/config

        mkdir -p /home/usr/.config/khal
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/khal/config /home/usr/.config/khal/config

        mkdir -p /home/usr/.config/khard
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/khard/khard.conf /home/usr/.config/khard/khard.conf

        mkdir -p /home/usr/.config/msmtp
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/msmtp/config /home/usr/.config/msmtp/config

        mkdir -p /home/usr/.config/neomutt
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/neomutt/neomuttrc /home/usr/.config/neomutt/neomuttrc

        mkdir -p /home/usr/.config/nvim
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/nvim/init.lua /home/usr/.config/nvim/init.lua
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/nvim/colors /home/usr/.config/nvim/colors

        mkdir -p /home/usr/.config/rbw
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/rbw/config.json /home/usr/.config/rbw/config.json

        mkdir -p /home/usr/.config/ssh
        mkdir -p /home/usr/.ssh
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/ssh/config /home/usr/.config/ssh/config
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/ssh/config /home/usr/.ssh/config

        mkdir -p /home/usr/.config/sx
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/sx/sxrc /home/usr/.config/sx/sxrc

        mkdir -p /home/usr/.config/sxhkd
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/sxhkd/sxhkdrc /home/usr/.config/sxhkd/sxhkdrc
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/sxhkd/mouse /home/usr/.config/sxhkd/mouse
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/sxhkd/nodemanip /home/usr/.config/sxhkd/nodemanip
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/sxhkd/vnc /home/usr/.config/sxhkd/vnc

        mkdir -p /home/usr/.config/todoman
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/todoman/config.py /home/usr/.config/todoman/config.py

        mkdir -p /home/usr/.config/vdirsyncer
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/vdirsyncer/config /home/usr/.config/vdirsyncer/config

        mkdir -p /home/usr/.config/xscreensaver
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/xscreensaver/.xscreensaver /home/usr/.config/xscreensaver/.xscreensaver

        mkdir -p /home/usr/.config/zathura
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/zathura/zathurarc /home/usr/.config/zathura/zathurarc

        mkdir -p /home/usr/.local/share
        ${pkgs.coreutils}/bin/ln -sf $config_prefix/pape.jpg /home/usr/.local/share/pape.jpg
      '';
      deps = [];
    };
  };
}
