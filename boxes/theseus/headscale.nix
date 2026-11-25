{ config, ... }:
{
  services.headscale = {
    enable = true;
    port = 8085;
    settings = {
      server_url = "https://hs.beepboop.systems";
      prefixes.allocation = "sequential";
      dns = {
        magic_dns = true;
        # must not be a parent of server_url's host
        base_domain = "ts.beepboop.systems";
        override_local_dns = false;
      };
    };
  };

  services.nginx.virtualHosts."hs.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
      proxyWebsockets = true; # required by the tailscale control protocol
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_buffering off;
      '';
    };
  };

  # let tailnet peers reach everything on theseus
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
