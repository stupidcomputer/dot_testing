{ lib, config, pkgs, ... }:

{
  imports =
    [
      ../modules/mail.nix
      ../common/main.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "netbox";

  users.users.useracc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  users.users.paperlesspassthrough = {
    isNormalUser = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    # nothing more needed, at the moment
  ];

  services.openssh = {
    enable = true;
    ports = [55555];
  };

  services.endlessh.enable = true;
  services.endlessh.port = 22;
  services.vaultwarden.enable = true;
  services.vaultwarden.config = {
  	DOMAIN = "https://bitwarden.beepboop.systems";
	SIGNUPS_ALLOWED = false;
  };

  networking.usePredictableInterfaceNames = false;

  services.nixosmail.enable = true;

  services.gitea = {
    enable = true;
    appName = "crappy code"; # Give the site a name
    database = {
      type = "postgres";
      passwordFile = "/etc/gittea-pass"; 
    };
    settings.server = {
      DOMAIN = "git.beepboop.systems";
      ROOT_URL = "https://git.beepboop.systems/";
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

  services.nginx.enable = true;
  services.nginx.clientMaxBodySize = "100m";

  services.nginx.virtualHosts."beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/beepboop.systems";
  };

  services.nginx.virtualHosts."git.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:3001";
  };

  services.nginx.virtualHosts."paperless.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:3004";
  };

  services.nginx.virtualHosts."bitwarden.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8000";
    };
  };

  services.nginx.virtualHosts."ntfy.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3500";
    };
  };

  services.nginx.virtualHosts."skillissue.agency" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/skillissue.agency";
  };

  security.acme = {
    acceptTerms = true;
    email = "nickforanick@protonmail.com";
  };

  services.roundcube = {
    enable = true;
    # this is the url of the vhost, not necessarily the same as the fqdn of
    # the mailserver
    hostName = "cube.beepboop.systems";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5232 55555 22 80 443 ];
  };

#  services.paperless = {
#    enable = true;
#    passwordFile = "/etc/paperless-password";
#    port = 3004;
#    address = "localhost";
#    extraConfig = {
#      PAPERLESS_URL = "https://paperless.beepboop.systems";
#    };
#  };
}
