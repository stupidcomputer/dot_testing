{ config, ... }:
{
  services.gitea = {
    enable = true;
    appName = "beepboop.systems"; # Give the site a name
    database = {
      type = "postgres";
      passwordFile = config.age.secrets.gitea-postgres-password.path;
    };
    settings.security.INSTALL_LOCK = true;
    settings.service = {
      SHOW_REGISTRATION_BUTTON = false;
      DISABLE_REGISTRATION = true;
    };
    settings.api.ENABLE_SWAGGER = false;
    settings.server = {
      DOMAIN = "git.beepboop.systems";
      ROOT_URL = "https://git.beepboop.systems/";
      LANDING_PAGE = "explore";
      HTTP_PORT = 3001;
    };
  };

  services.postgresql = {
    enable = true;                # Ensure postgresql is enabled
    authentication = ''
      local gitea all ident map=gitea-users
    '';
    identMap =                    # Map the gitea user to postgresql
      ''
        gitea-users gitea gitea
      '';
  };

  services.nginx.virtualHosts."git.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3001";
    };
    locations."/bridge" = {
      proxyPass = "http://localhost:5000";
    };
  };
}
