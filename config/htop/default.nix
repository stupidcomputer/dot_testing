{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    htop
  ];

  system.userActivationScripts.copyCmusConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/htop
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/htop/htoprc /home/usr/.config/htop/htoprc
    '';
    deps = [];
  };
}
