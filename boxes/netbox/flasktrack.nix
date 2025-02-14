{ pkgs, ... }:
let
  appEnv = pkgs.python3.withPackages (p: with p; [
    (callPackage ../../builds/flasktrack.nix {})
    waitress
  ]);
in {
  systemd.services.flasktrack = {
    wantedBy = [ "multi-user.target" ];
    environment = {
      FLASKTRACK_CREDENTIAL_LOCATION = "/etc/flasktrack-secrets.cfg";
    };
    serviceConfig = {
      ExecStart = "${appEnv}/bin/waitress-serve --port=8042 flasktrack:app";
      StandardOutput = "journal";
    };
  };

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
