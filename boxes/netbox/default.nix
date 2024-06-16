{ lib, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/bootstrap.nix
      ../../builds/gmail_mail_bridge.nix
    ];

  # nix optimization
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    python3
    curl
    htop
    git
    tree
    dig
    htop
    neovim
  ];

  services.gmail_mail_bridge.enable = true;

  system.copySystemConfiguration = true;
  system.stateVersion = "23.05"; # don't change this, lol
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  services.sslh = {
    enable = true;
    settings.protocols = [
      {
        host = "localhost";
        name = "ssh";
        port = "55555";
        service = "ssh";
      }
      {
        host = "localhost";
          name = "tls";
          port = "442";
      }
    ];
  };

  networking.hostName = "netbox";

  services.radicale = {
    enable = true;
    config = ''
      [auth]
      type = htpasswd
      htpasswd_filename = radicale-passwd
      htpasswd_encryption = plain
    '';
  };

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

  users.users.ryan = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbhM3wj0oqjR3pUaZgpfX4Xo4dlzvBTbQ48zHyg7Pwx usr" # x230t
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrpVDLQszFKoYbvYKRyVTTpehxR0BVU47SXkz39l2wK usr" # mainsail
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZw5bg0TrvSkW/XQa4c+2iLbIKOxfMGbjy5Nb3HSfBv usr" # phone
    ];
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

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

  services.gitea = {
    enable = true;
    appName = "beepboop.systems"; # Give the site a name
    database = {
      type = "postgres";
      passwordFile = "/etc/gittea-pass"; 
    };
    settings.security.INSTALL_LOCK = true;
    settings.service.SHOW_REGISTRATION_BUTTON = false;
    settings.ui.DEFAULT_THEME = "arc-green";
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

  services.nginx.enable = true;
  services.nginx.clientMaxBodySize = "100m";
  services.nginx.defaultSSLListenPort = 442;

  services.nginx.virtualHosts."beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/beepboop.systems";
  };

  services.nginx.virtualHosts."git.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3001";
    };
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

  services.nginx.virtualHosts."skillissue.agency" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/skillissue.agency";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nickforanick@protonmail.com";
  };

#  services.roundcube = {
#    enable = true;
#    # this is the url of the vhost, not necessarily the same as the fqdn of
#    # the mailserver
#    hostName = "cube.beepboop.systems";
#    extraConfig = ''
#      # starttls needed for authentication, so the fqdn required to match
#      # the certificate
#      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
#      $config['smtp_user'] = "%u";
#      $config['smtp_pass'] = "%p";
#    '';
#  };

  services.nginx.virtualHosts."roundcube.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    globalRedirect = "cube.beepboop.systems";
  };

  services.nginx.virtualHosts."mail.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/bridge-submit" = {
      extraConfig = ''
        proxy_pass http://localhost:8041;
      '';
    };
    locations."/" = {
      extraConfig = ''
        return 301 https://cube.beepboop.systems;
      '';
    };
  };

  services.bitlbee = {
    enable = true;
    hostName = "beepboop.systems";
    plugins = with pkgs; [
      bitlbee-steam
      bitlbee-discord # shhhhhhhhh
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 6667 ];
  };
}
