{ config, pkgs, lib, machines, ... }:
let
  # the only machines allowed to be exit nodes. headscale leaves routes
  # unapproved by default, so nothing else becomes one
  exitNodes = [ machines.theseus machines.copernicus ];
in
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

  systemd.services.headscale-exit-nodes = {
    description = "approve exit nodes in headscale";
    wantedBy = [ "multi-user.target" ];
    requires = [ "headscale.service" ];
    after = [ "headscale.service" ];
    path = [ config.services.headscale.package pkgs.jq ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    # approve-routes replaces the node's whole list of approved routes
    script = ''
      nodes=$(headscale nodes list -o json)
      for ip in ${lib.escapeShellArgs (map (m: m.ip-addrs.intnet) exitNodes)}; do
        id=$(jq -r --arg ip "$ip" '.[] | select(.ip_addresses | index($ip)) | .id' <<< "$nodes")
        if [ -z "$id" ]; then
          echo "no node with address $ip, skipping" >&2
          continue
        fi
        headscale nodes approve-routes --identifier "$id" --routes "0.0.0.0/0,::/0"
      done
    '';
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
