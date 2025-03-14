{ pkgs, ... }:
let
  flasktrack = (pkgs.callPackage ../../builds/flasktrack.nix {});
  appEnv = pkgs.python3.withPackages (p: with p; [
    waitress
    flask
  ]);

in {
  systemd.services.flasktrack = {
    wantedBy = [ "multi-user.target" ];
    environment = {
      FLASKTRACK_CREDENTIAL_LOCATION = "/etc/flasktrack-secrets.cfg";
      FLASK_DATABASE_LOCATION = "/run/flasktrack/database.json";
    };
    serviceConfig = {
      WorkingDirectory = "${flasktrack}/lib/python3.12/site-packages";
      RuntimeDirectory = "${flasktrack}/lib/python3.12/site-packages";
      ExecStart = "${appEnv}/bin/waitress-serve --port=8042 flasktrack:app";
      StandardOutput = "journal";
      User = "flasktrack";
    };
  };

  users.users.flasktrack = {
    isSystemUser = true;
    home = "/run/flasktrack";
    homeMode = "700";
    createHome = true;
    group = "flasktrack";
  };

  users.groups.flasktrack = {};

  services.nginx.virtualHosts."flasktrack.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      extraConfig = ''
        proxy_pass http://localhost:8042;
      '';
    };
  };
}
