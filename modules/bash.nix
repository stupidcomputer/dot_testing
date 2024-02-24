{ lib, config, pkgs, ...}:

{
  # make the home-manager .config/bash/(profile/bashrc) work
  environment.etc = {
    "profile.local" = {
      text = "source /home/usr/.config/bash/profile";
    };
    "bashrc.local" = {
      text = "source /home/usr/.config/bash/bashrc";
    };
  };

  environment.systemPackages = with pkgs; [
    fzy
  ];
}
