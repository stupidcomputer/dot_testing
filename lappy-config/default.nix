{ config, pkgs, ... }:

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

  system.userActivationScripts = {
    copyEssentialConfiguration = {
      text = ''
        mkdir -p /home/usr/.config/bash
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/bash/bashrc /home/usr/.config/bash/bashrc
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/bash/profile /home/usr/.config/bash/profile

        mkdir -p /home/usr/.config/cmus
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/cmus/rc /home/usr/.config/cmus/rc

        mkdir -p /home/usr/.config/git
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/git/config /home/usr/.config/git/config

        mkdir -p /home/usr/.config/isync
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/isync/config /home/usr/.config/isync/config

        mkdir -p /home/usr/.config/khal
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/khal/config /home/usr/.config/khal/config

        mkdir -p /home/usr/.config/khard
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/khard/khard.conf /home/usr/.config/khard/khard.conf

        mkdir -p /home/usr/.config/lynx
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/lynx/lynx.cfg /home/usr/.config/lynx/lynx.cfg

        mkdir -p /home/usr/.config/msmtp
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/msmtp/config /home/usr/.config/msmtp/config

        mkdir -p /home/usr/.config/neomutt
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/neomutt/neomuttrc /home/usr/.config/neomutt/neomuttrc

        mkdir -p /home/usr/.config/nvim
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/nvim/init.lua /home/usr/.config/nvim/init.lua

        mkdir -p /home/usr/.config/python
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/python/pythonrc.py /home/usr/.config/python/pythonrc.py

        mkdir -p /home/usr/.config/rbw
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/rbw/config.json /home/usr/.config/rbw/config.json

        mkdir -p /home/usr/.config/ssh
        mkdir -p /home/usr/.ssh
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/ssh/config /home/usr/.config/ssh/config
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/ssh/config /home/usr/.ssh/config

        mkdir -p /home/usr/.config/sx
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/sx/sxrc /home/usr/.config/sx/sxrc

        mkdir -p /home/usr/.config/tmux
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/tmux/tmux.conf /home/usr/.config/tmux/tmux.conf

        mkdir -p /home/usr/.config/todoman
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/todoman/config.py /home/usr/.config/todoman/config.py

        mkdir -p /home/usr/.config/vdirsyncer
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy-config/vdirsyncer/config /home/usr/.config/vdirsyncer/config
      '';
      deps = [];
    };
  };
}
