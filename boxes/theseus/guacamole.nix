{ pkgs, config, ... }:
let
  guacdPort = 5929;
in {
  age.secrets.guac-user-mapping = {
    file = ../../secrets/guac-user-mapping.xml.age;
    owner = "tomcat";
  };
  
  services.guacamole-server = {
    enable = true;
    port = guacdPort;
    host = "127.0.0.1";
  };

  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    userMappingXml = config.age.secrets.guac-user-mapping.path;
    settings = {
      guacd-port = guacdPort;
      guacd-hostname = "127.0.0.1";
    };
  };

  services.nginx = {
    virtualHosts."guacamole.beepboop.systems" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080/guacamole/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Host $host;
        '';
      };
    };
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINStbAzzYb+xtm0bvAYf4su0JRHC3F4s1iPqqU0VCAd6"
  ];

  fonts.packages = [
    pkgs.fantasque-sans-mono
  ];
}
