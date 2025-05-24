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

      "tfb.beepboop.systems" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          extraConfig = ''
            return 301 https://marching.beepboop.systems;
          '';
        };
        locations."/groupme" = {
          proxyPass = "http://10.100.0.2:7439";
        };
      };

      "marching.beepboop.systems" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/tfb.beepboop.systems";
        locations."/" = {
          extraConfig = ''
            port_in_redirect off;
            absolute_redirect off;
          '';
        };
        locations."/groupme" = {
          proxyPass = "http://10.100.0.2:7439";
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

  services.nginx.virtualHosts."git.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      extraConfig = ''
        return 301 https://github.com/stupidcomputer;
      '';
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nickforanick@protonmail.com";
  };

  users.groups.nginx-data = {
    name = "nginx-data";
    members = [ "nginx" "ryan" ];
  };
}
