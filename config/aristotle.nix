{ pkgs, ... }:
{
  imports = [
    ./sx
  ];

  # make the bashrc go in .config/bash, not the home directory
  environment.etc = {
    "profile.local" = {
      text = "source /home/usr/.config/bash/profile";
    };
    "bashrc.local" = {
      text = "source /home/usr/.config/bash/bashrc";
    };
  };

  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];

  environment.systemPackages = with pkgs; [
    # x11
    brave
    qutebrowser
    (callPackage ../builds/st.nix { aristotle = true; })
    (callPackage ../builds/dmenu.nix {})
    (callPackage ../builds/utils.nix {})
    (callPackage ../builds/rebuild.nix {})
    (callPackage ../builds/dwm.nix {})
    (callPackage ../builds/sssg.nix {})
    pinentry-qt

    # tui/cli programs
    # devel
    gh
    tea
    neovim
    git
    git-annex

    # audio
    cmus
    ncpamixer
    bluetuith

    # pimtools
    khard
    khal
    vdirsyncer
    neomutt
    isync
    msmtp
    todoman

    # utilities
    htop
    tmux
    rbw
    elinks
    lynx
    jq
    peaclock
    usbutils # for lsusb
    pciutils # for lspci
    kjv
    epr
    poppler_utils
    ledger
    gnuplot
    anki-bin
    scrcpy
    x11vnc

    # for the remote access functionality
    vscode-fhs
  ];

  system.userActivationScripts = {
    copyEssentialConfiguration = {
      text = ''
        mkdir -p /home/usr/.config/bash
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/bash/bashrc /home/usr/.config/bash/bashrc
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/bash/profile /home/usr/.config/bash/profile

        mkdir -p /home/usr/.config/cmus
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/cmus/rc /home/usr/.config/cmus/rc

        mkdir -p /home/usr/.config/git
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/git/config /home/usr/.config/git/config

        mkdir -p /home/usr/.config/isync
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/isync/config /home/usr/.config/isync/config

        mkdir -p /home/usr/.config/khal
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/khal/config /home/usr/.config/khal/config

        mkdir -p /home/usr/.config/khard
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/khard/khard.conf /home/usr/.config/khard/khard.conf

        mkdir -p /home/usr/.config/msmtp
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/msmtp/config /home/usr/.config/msmtp/config

        mkdir -p /home/usr/.config/neomutt
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/neomutt/aristotle_neomuttrc /home/usr/.config/neomutt/neomuttrc

        mkdir -p /home/usr/.config/nvim
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/nvim/init.min.lua /home/usr/.config/nvim/init.lua

        mkdir -p /home/usr/.config/python
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/python/pythonrc.py /home/usr/.config/python/pythonrc.py

        mkdir -p /home/usr/.config/rbw
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/rbw/config.json /home/usr/.config/rbw/config.json

        mkdir -p /home/usr/.config/ssh
        mkdir -p /home/usr/.ssh
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/ssh/config /home/usr/.config/ssh/config
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/ssh/config /home/usr/.ssh/config

        mkdir -p /home/usr/.config/sx
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/sx/aristotle /home/usr/.config/sx/sxrc

        mkdir -p /home/usr/.config/todoman
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/todoman/config.py /home/usr/.config/todoman/config.py

        mkdir -p /home/usr/.config/vdirsyncer
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/vdirsyncer/config /home/usr/.config/vdirsyncer/config
      '';
      deps = [];
    };
  };
}
