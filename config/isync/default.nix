{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    isync
  ];

  system.userActivationScripts.copyIsyncConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/isync
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/isync/aristotle-config /home/usr/.config/isync/config
    '';
    deps = [];
  };
}
