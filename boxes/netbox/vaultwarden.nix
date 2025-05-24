{ pkgs, config, ...}:
{
  age.secrets.vaultwarden = {
    file = ../../secrets/vaultwarden-secret.age;
    owner = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden.path;
    config = {
      DOMAIN = "https://bitwarden.beepboop.systems";
      SIGNUPS_ALLOWED = false;
    };
  };

  services.nginx.virtualHosts."bit.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    globalRedirect = "bitwarden.beepboop.systems";
  };

  services.nginx.virtualHosts."bitwarden.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8000";
    };
  };

  # backup stuff
  systemd.timers."vaultwarden-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1d";
      Unit = "vaultwarden-backup.service";
    };
  };

  systemd.services."vaultwarden-backup" = {
    script = ''
      cd /var/lib/bitwarden_rs
      ${pkgs.coreutils}/bin/mkdir -p /annex/ryan/vaultwarden-backup
      ${pkgs.sqlite}/bin/sqlite3 db.sqlite3 ".backup '/annex/ryan/vaultwarden-backup/backup.sqlite3'"
      ${pkgs.coreutils}/bin/chown -R ryan /annex/ryan/vaultwarden-backup
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
