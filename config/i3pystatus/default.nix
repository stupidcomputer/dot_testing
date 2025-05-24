{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    i3pystatus
  ];

  system.userActivationScripts.copyI3pystatusConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/i3pystatus
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/i3pystatus/config.py /home/usr/.config/i3pystatus/config.py
    '';
    deps = [];
  };
}
