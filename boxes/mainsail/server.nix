{ lib, config, pkgs, ...}:
{
  services.paperless = {
    enable = true;
    passwordFile = "/etc/paperless-password";
    port = 3004;
    address = "localhost";
    extraConfig = {
      PAPERLESS_URL = "https://paperless.beepboop.systems";
    };
  };

  services.calibre-web.enable = true;
  services.calibre-web.listen.port = 8080;

  programs.adb.enable = true;
  users.users.usr.extraGroups = ["adbusers"];

  services.openssh = {
    enable = true;
    ports = [2222];
  };

  services.radicale = {
    enable = true;
    config = ''
      [auth]
      type = htpasswd
      htpasswd_filename = radicale-passwd
      htpasswd_encryption = plain
    '';
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  systemd.services.paperless-web-bridge = {
    script = ''
      ${pkgs.openssh}/bin/ssh -v -NR 3004:localhost:3004 -oExitOnForwardFailure=yes -p 55555 useracc@beepboop.systems
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "ankisyncd.service" ];
    serviceConfig = {
      Restart = "on-failure";
      StartLimitInterval = 0;
      StartLimitBurst = 10000;
      RestartSec = "0s";
    };
  };

  systemd.services.radicale-web-bridge = {
    script = ''
      ${pkgs.openssh}/bin/ssh -v -NR 5232:localhost:5232 -oExitOnForwardFailure=yes -p 55555 useracc@beepboop.systems
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "ankisyncd.service" ];
    serviceConfig = {
      Restart = "on-failure";
      StartLimitInterval = 0;
      StartLimitBurst = 10000;
      RestartSec = "0s";
    };
  };

  systemd.services.internal-ssh-bridge = {
    script = ''
      ${pkgs.openssh}/bin/ssh -v -NR 2222:localhost:2222 -oExitOnForwardFailure=yes -p 55555 useracc@beepboop.systems
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "ankisyncd.service" ];
    serviceConfig = {
      Restart = "on-failure";
      StartLimitInterval = 0;
      StartLimitBurst = 10000;
      RestartSec = "0s";
    };
  };
}
