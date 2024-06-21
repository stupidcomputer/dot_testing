{ lib, config, pkgs, ... }:
{
  services.vaultwarden.enable = true;
  services.vaultwarden.config = {
    DOMAIN = "https://bitwarden.beepboop.systems";
    SIGNUPS_ALLOWED = false;
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
}
