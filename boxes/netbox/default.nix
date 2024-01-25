{ lib, config, pkgs, ... }:

let
  cgitrc = pkgs.writeText "cgitrc" ''
    css=/static/cgit.css
    logo=/static/logo.png
    favicon=/static/favicon.ico
    root-title=beepboop.systems
    root-desc=quality git hosting

    readme=:README
    readme=:readme
    readme=:readme.txt
    readme=:README.txt
    readme=:readme.md
    readme=:README.md

    remove-suffix=1
    section-from-path=1

    section-sort=0

    section=meta

    repo.url=about
    repo.path=/doesnt/exist
    repo.desc=about this site

    section=other services at beepboop.systems

    repo.url=bitwarden
    repo.path=/doesnt/exist
    repo.desc=a simple password manager

    repo.url=radicale
    repo.path=/doesnt/exist
    repo.desc=a simple calendar server

    repo.url=roundcube
    repo.path=/doesnt/exist
    repo.desc=mail.beepboop.systems webmail

    repo.url=gitea
    repo.path=/doesnt/exist
    repo.desc=real git hosting services (until this one is fully operational)

    section=projects

    repo.url=advent
    repo.path=/var/lib/git/advent
    repo.desc=advent of code solutions

    repo.url=desmos-computer
    repo.path=/var/lib/git/desmos-computer
    repo.desc=a minimal ISA implemented in the Desmos graphing calculator

    repo.url=dot_testing
    repo.path=/var/lib/git/dot_testing
    repo.desc=configuration files for NixOS/GNU+Linux boxes

    repo.url=esgd
    repo.path=/var/lib/git/esgd
    repo.desc=the exceedingly simple gopher daemon

    repo.url=mail-sync
    repo.path=/var/lib/git/mail-sync
    repo.desc=synchronize mail from walled gardens

    repo.url=mastosnake
    repo.path=/var/lib/git/mastosnake
    repo.desc=a low quality clone of Twitter Plays Snake

    repo.url=secmsg
    repo.path=/var/lib/git/secmsg
    repo.desc=a stupid (in)secure messaging client thing

    repo.url=ultimate
    repo.path=/var/lib/git/ultimate
    repo.desc=ultimate tic tac toe solving engine

    repo.url=wordlefish
    repo.path=/var/lib/git/wordlefish
    repo.desc=use information theory to solve wordle puzzles

    section=irc robots

    repo.url=botanybot
    repo.path=/var/lib/git/botanybot
    repo.desc=water bots on ~.club

    repo.url=coinminer
    repo.path=/var/lib/git/coinminer
    repo.desc=mine fake coins on irc

    repo.url=chaosbot
    repo.path=/var/lib/git/chaosbot
    repo.desc=robot to protect a user on chaos

    repo.url=modbot
    repo.path=/var/lib/git/modbot
    repo.desc=modular irc robot

    repo.url=pychaos
    repo.path=/var/lib/git/pychaos
    repo.desc=python chaos bot

    repo.url=universalducks
    repo.path=/var/lib/git/universalducks
    repo.desc=cross channel irc ducks
  '';
in {
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/bootstrap.nix
      ../../builds/gmail_mail_bridge.nix
    ];

  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    curl
    htop
    git
    tree
    dig
    htop
    gnumake
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

  # cgit
  users = {
    groups.git = { };
    users.git = {
      createHome = true;
      home = /var/lib/git;
      isSystemUser = true;
      shell = "${pkgs.git}/bin/git-shell";
      group = "git";
    };
  };

  services.fcgiwrap = { enable = true; user = "git"; group = "git"; };

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbhM3wj0oqjR3pUaZgpfX4Xo4dlzvBTbQ48zHyg7Pwx usr"
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
  services.nginx.defaultSSLListenPort = 442;

  services.nginx.virtualHosts."beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    root = "/var/www/beepboop.systems";

    locations."~* ^/static/(.+.(ico|css))$" = {
      extraConfig = ''
        alias ${pkgs.cgit}/cgit/$1;
      '';
    };
    locations."/static/logo.png" = {
      extraConfig = ''
        try_files /icon.png /icon.png;
      '';
    };
    locations."/about" = {
      extraConfig = ''
        try_files /about.html /about.html;
      '';
    };
    locations."/bitwarden" = {
      extraConfig = ''
        return 301 https://bit.beepboop.systems;
      '';
    };
    locations."/gitea" = {
      extraConfig = ''
        return 301 https://git.beepboop.systems/rndusr;
      '';
    };
    locations."/radicale" = {
      extraConfig = ''
        return 301 https://cal.beepboop.systems;
      '';
    };
    locations."/roundcube" = {
      extraConfig = ''
        return 301 https://mail.beepboop.systems;
      '';
    };
    locations."~ \\.git" = {
      extraConfig = ''
        client_max_body_size 0;
        
        include ${pkgs.nginx}/conf/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME ${pkgs.git}/bin/git-http-backend;
        fastcgi_param GIT_HTTP_EXPORT_ALL "";
        fastcgi_param GIT_PROJECT_ROOT /var/lib/git;
        fastcgi_param PATH_INFO $uri;
        
        # Forward REMOTE_USER as we want to know when we are authenticated
        fastcgi_param REMOTE_USER $remote_user;
        fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
      '';
    };
    locations."/" = {
      extraConfig = ''
        include ${pkgs.nginx}/conf/fastcgi_params;
        fastcgi_param CGIT_CONFIG ${cgitrc};
        fastcgi_param SCRIPT_FILENAME ${pkgs.cgit}/cgit/cgit.cgi;
        fastcgi_split_path_info ^(/?)(.+)$;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param QUERY_STRING $args;
        fastcgi_param HTTP_HOST $server_name;
        fastcgi_pass unix:${config.services.fcgiwrap.socketAddress};
      '';
    };
  };

  services.nginx.virtualHosts."git.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://localhost:3001";
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
}
