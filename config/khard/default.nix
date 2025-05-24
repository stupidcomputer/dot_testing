{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    khard
  ];

  system.userActivationScripts.copyKhardConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/khard
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/khard/khard.conf /home/usr/.config/khard/khard.conf
    '';
    deps = [];
  };
}
