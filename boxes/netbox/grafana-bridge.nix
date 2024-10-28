{ lib, config, pkgs, ... }:
{
  services.nginx.virtualHosts."grafana.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://10.100.0.2:9802";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_buffering off;
      '';
    };
  };
}
