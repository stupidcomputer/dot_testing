{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    i3
    i3lock

    pw-volume
  ];

  system.userActivationScripts.copyI3Configuration = {
    text = ''
      mkdir -p /home/usr/.config/i3
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/i3/config /home/usr/.config/i3/config
    '';
    deps = [];
  };
}
