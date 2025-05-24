{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    msmtp
  ];

  system.userActivationScripts.copyMsmtpConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/msmtp
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/msmtp/config /home/usr/.config/msmtp/config
    '';
    deps = [];
  };
}
