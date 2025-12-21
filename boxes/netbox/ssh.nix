{ pkgs, machines, ... }:
{
  services.openssh = {
    enable = true;
    ports = [55555];
    settings = {
      X11Forwarding = false;
      AllowTcpForwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  users.users.ryan.openssh.authorizedKeys.keys = [
    machines.copernicus.pubkey
    machines.hammurabi.pubkey
    machines.phone.pubkey
  ];

  # save ip addresses in cache from repeat logins
  services.nginx.virtualHosts."localhost" = {
    listen = [{ addr = "127.0.0.1"; port = 9414; }];
    extraConfig = ''
      location / {
        proxy_pass_request_headers off;
        proxy_pass https://ipinfo.io/;
        proxy_cache_key $scheme://$host$uri$is_args$query_string;
        proxy_cache_valid 203 1d;
      }
    '';
  };
}
