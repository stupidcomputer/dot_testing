{ machines, ... }:

{
  networking = {
    firewall.allowedUDPPorts = [ 50000 ];

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.2/24" ];
        listenPort = 50000;

        privateKeyFile = "/home/usr/wg-keys/private";
        peers = [
          { # netbox
            publicKey = machines.wg-pubkey;
            allowedIPs = [ "10.100.0.0/24" ]; # only stuff in the wg-subnet (10.100.0.*)
            endpoint = "149.28.63.115:50000";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
