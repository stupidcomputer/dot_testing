{ lib, config, pkgs, ... }:
{
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
}
