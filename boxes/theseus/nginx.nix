{ pkgs, machines, ... }:
{
  services.nginx = {
    enable = true;
    clientMaxBodySize = "100m";
    defaultSSLListenPort = 442;
    appendHttpConfig = ''
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
      "intnet.beepboop.systems" = {
        root = "/var/www/intnet.beepboop.systems";
        listen = [ { addr = machines.theseus.ip-addrs.intnet; port = 80; ssl = false; } ];
      };
    };
  };

  system.activationScripts = {
    "ensureWebDirectories" = {
      text = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/www/tools.beepboop.systems
        ${pkgs.coreutils}/bin/chown nginx:nginx-data /var/www/tools.beepboop.systems
        ${pkgs.coreutils}/bin/chmod -R u=rwX,g=rwX,o=r /var/www/tools.beepboop.systems
        ${pkgs.coreutils}/bin/chmod g+s /var/www/tools.beepboop.systems
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
