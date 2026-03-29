{ pkgs, ... }:
{
  services.nginx = {
    enable = true;
    clientMaxBodySize = "100m";
    defaultSSLListenPort = 442;
    appendHttpConfig = ''
      proxy_cache_path /tmp/proxy_cache levels=1:2 keys_zone=cachecache:100m max_size=1g inactive=365d use_temp_path=off;
      map $status $cache_header {
        200     "public";
        302     "public";
        default "no-cache";
      }

      error_log stderr;
      access_log syslog:server=unix:/dev/log combined;
    '';

    virtualHosts = {
      "beepboop.systems" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          extraConfig = ''
            port_in_redirect off;
            absolute_redirect off;
          '';
          proxyPass = "https://stupidcomputer.github.io/stupidcomputer/";
        };
      };
      "tsa-webmaster-26.beepboop.systems" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://68.84.80.81:9194";
          extraConfig = ''
            port_in_redirect off;
            absolute_redirect off;
          '';
        };
      };
      "tools.beepboop.systems" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/tools.beepboop.systems";
        locations."/" = {
          extraConfig = ''
            port_in_redirect off;
            absolute_redirect off;
          '';
        };
      };
    };
  };

  system.activationScripts = {
    "ensureWebDirectories" = {
      text = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/www/tools.beepboop.systems
        ${pkgs.coreutils}/bin/mkdir -p /var/www/tsa-webmaster-26-placeholder.beepboop.systems
        ${pkgs.coreutils}/bin/chown nginx:nginx-data /var/www/tools.beepboop.systems
        ${pkgs.coreutils}/bin/chown nginx:nginx-data /var/www/tsa-webmaster-26-placeholder.beepboop.systems
        ${pkgs.coreutils}/bin/chmod -R u=rwX,g=rwX,o=r /var/www/tools.beepboop.systems
        ${pkgs.coreutils}/bin/chmod -R u=rwX,g=rwX,o=r /var/www/tsa-webmaster-26-placeholder.beepboop.systems
        ${pkgs.coreutils}/bin/chmod g+s /var/www/tools.beepboop.systems
        ${pkgs.coreutils}/bin/chmod g+s /var/www/tsa-webmaster-26-placeholder.beepboop.systems
      ''; 
    };
  };

  systemd.services.nginx.serviceConfig.ProtectHome = false;

  security.acme = {
    acceptTerms = true;
    defaults.email = "nickforanick@protonmail.com";
  };

  users.groups.nginx-data = {
    name = "nginx-data";
    members = [ "nginx" ];
  };
}
