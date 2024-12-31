{ config, ... }:
{
  services.radicale = {
    enable = true;
    settings = {
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale-passwd.path;
        htpasswd_encryption = "plain";
      };
    };
  };

  services.nginx.virtualHosts."radicale.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5232";
      extraConfig = ''
        proxy_set_header  X-Script-Name /;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass_header Authorization;
      '';
    };
  };

  services.nginx.virtualHosts."calendar.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    globalRedirect = "radicale.beepboop.systems";
  };

  services.nginx.virtualHosts."cal.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    globalRedirect = "radicale.beepboop.systems";
  };
}
