{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vdirsyncer
  ];

  system.userActivationScripts.copyVdirsyncerConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/vdirsyncer
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/vdirsyncer/config /home/usr/.config/vdirsyncer/config
    '';
    deps = [];
  };
}
