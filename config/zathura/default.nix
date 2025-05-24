{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zathura
  ];

  system.userActivationScripts.copyZathuraConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/zathura
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/zathura/zathurarc /home/usr/.config/zathura/zathurarc
    '';
    deps = [];
  };
}
