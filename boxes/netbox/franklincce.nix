{ lib, config, pkgs, ... }:
{
  virtualisation.docker.enable = true;

  services.nginx.virtualHosts."franklincce.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:1337";
    };
  };
}
