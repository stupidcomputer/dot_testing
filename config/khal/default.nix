{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    khal
  ];

  system.userActivationScripts.copyKhalConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/khal
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/khal/config /home/usr/.config/khal/config
    '';
    deps = [];
  };
}
