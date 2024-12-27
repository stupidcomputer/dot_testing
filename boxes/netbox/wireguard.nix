{ config, machines, pkgs, ... }:

{
  networking = {
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
    };
    firewall.allowedUDPPorts = [ 50000 ];

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];

        listenPort = 50000;

        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';

        privateKeyFile = config.age.secrets.netbox-wg-priv.path;

        peers = [
          { # copernicus
            publicKey = machines.copernicus.wg-pubkey;
            allowedIPs = [ "10.100.0.2/32" ];
          }
          { # aristotle
            publicKey = machines.aristotle.wg-pubkey;
            allowedIPs = [ "10.100.0.3/32" ];
          }
        ];
      };
    };
  };
}
