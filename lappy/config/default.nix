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
        mkdir -p /home/usr/.config

        mkdir -p /home/usr/.config/nvim
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy/config/nvim/init.lua /home/usr/.config/nvim/init.lua

        mkdir -p /home/usr/.config/sx
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy/config/sx/sxrc /home/usr/.config/sx/sxrc

        mkdir -p /home/usr/.config/bash
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy/config/bash/bashrc /home/usr/.config/bash/bashrc
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy/config/bash/profile /home/usr/.config/bash/profile

        mkdir -p /home/usr/.config/git
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy/config/git/config /home/usr/.config/git/config

        mkdir -p /home/usr/.config/rbw
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy/config/rbw/config.json /home/usr/.config/rbw/config.json

        mkdir -p /home/usr/.config/cmus
        ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/lappy/config/cmus/rc /home/usr/.config/cmus/rc
      '';
      deps = [];
    };
  };
}
