{ pkgs, ... }:
{
  environment.etc = {
    "profile.local" = {
      text = "source /home/usr/.config/bash/profile";
    };
    "bashrc.local" = {
      text = "source /home/usr/.config/bash/bashrc";
    };
  };

  environment.systemPackages = with pkgs; [
    bash
  ];

  system.userActivationScripts.copyBashConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/bash
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/bash/bashrc /home/usr/.config/bash/bashrc
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/bash/profile /home/usr/.config/bash/profile
    '';
    deps = [];
  };
}
