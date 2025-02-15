{
  services.nginx = {
    enable = true;
    clientMaxBodySize = "100m";
    defaultSSLListenPort = 442;

    virtualHosts = {
      "beepboop.systems" = {
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
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nickforanick@protonmail.com";
  };
}
