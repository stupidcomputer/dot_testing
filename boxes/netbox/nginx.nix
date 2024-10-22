{ lib, config, pkgs, ... }:
{
  services.nginx.enable = true;
  services.nginx.clientMaxBodySize = "100m";
  services.nginx.defaultSSLListenPort = 442;

  services.nginx.virtualHosts."beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/beepboop.systems";
    locations."/" = {
      extraConfig = ''
        port_in_redirect off;
        absolute_redirect off;
      '';
    };
  };

  services.nginx.virtualHosts."tfb.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/tfb.beepboop.systems";
    locations."/" = {
      extraConfig = ''
        port_in_redirect off;
        absolute_redirect off;
      '';
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nickforanick@protonmail.com";
  };
}
