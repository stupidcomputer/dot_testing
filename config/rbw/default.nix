{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rbw
    pinentry-qt
  ];

  system.userActivationScripts.copyRbwConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/rbw
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/rbw/config.json /home/usr/.config/rbw/config.json
    '';
    deps = [];
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };

  security.polkit = {
    enable = true;
  };
}
