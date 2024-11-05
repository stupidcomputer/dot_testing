{ lib, config, pkgs, ... }:
{
  services.nginx.virtualHosts."nextcloud.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://10.100.0.2:5028";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_buffering off;
      '';
    };
  };
}
