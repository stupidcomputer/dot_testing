{ lib, config, pkgs, ... }:
{
  services.nginx.virtualHosts."rcon.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://10.100.0.2:6733";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_buffering off;

        port_in_redirect off;
        absolute_redirect off;

        location = / {
          return 301 /guacamole/;
        }
      '';
    };
  };
}
