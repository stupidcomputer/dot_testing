{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    todoman
  ];

  system.userActivationScripts.copyTodomanConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/todoman
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/todoman/config.py /home/usr/.config/todoman/config.py
    '';
    deps = [];
  };
}
