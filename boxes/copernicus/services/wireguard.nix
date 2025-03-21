{ config, machines, ... }:
{
  networking = {
    firewall.allowedUDPPorts = [ 50001 ];

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.2/24" ];
        listenPort = 50001;

        privateKeyFile = config.age.secrets.copernicus-wg-priv.path;
        peers = [
          { # netbox
            publicKey = machines.netbox.wg-pubkey;
            allowedIPs = [ "10.100.0.0/24" ]; # only stuff in the wg-subnet (10.100.0.*)
            endpoint = "149.28.63.115:50001";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
