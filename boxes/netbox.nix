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

  services.rss2email = {
    enable = true;
    to = "ryan@beepboop.systems";
    feeds = {
      "eff" = {
        url = "https://www.eff.org/rss/updates.xml";
      };
      "nixos" = {
        url = "https://nixos.org/blog/announcements-rss.xml";
      };
      "drewdevault" = {
        url = "https://drewdevault.com/blog/index.xml";
      };
      "nullprogram" = {
        url = "https://nullprogram.com/feed/";
      };
    };
  };

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "192.168.1.0/24"
    ];
    extraPackages = [pkgs.ipset];
    banaction = "iptables-ipset-proto6-allports";

    jails = {
      "nginx-bruteforce" = ''
        enabled = true
	filter = nginx-bruteforce
	logpath = /var/log/nginx/access.log
	backend = auto
	maxretry = 6
	findtime = 600
      '';

      "postfix-bruteforce" = ''
        enabled = true
	filter = postfix-bruteforce
	maxretry = 6
	findtime = 600
      '';
    };
  };

  environment.etc = {
    "fail2ban/filter.d/nginx-bruteforce.conf".text = ''
      [Definition]
      failregex = ^<HOST>.*GET.*(matrix/server|\.php|admin|wp\-).* HTTP/\d.\d\" 404.*$
    '';

    "fail2ban/filter.d/postfix-bruteforce.conf".text = ''
      [Definition]
      failregex = warning: [\w\.\-]+\[<HOST>\]: SASL LOGIN authentication failed.*$
      journalmatch = _SYSTEMD_UNIT=postfix.service
    '';
  };

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
