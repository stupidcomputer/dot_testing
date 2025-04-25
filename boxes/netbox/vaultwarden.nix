{
  services.vaultwarden.enable = true;
  services.vaultwarden.config = {
    DOMAIN = "https://bitwarden.beepboop.systems";
    SIGNUPS_ALLOWED = false;
    ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$m+sHaP9BLx2IVDJllxaybmiUUFShwUGma+o9Sj9xNeo$l65x0X1VqGnwOGk/3UXvezY7CEY+Viv4s2dTY9KREpI";
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
