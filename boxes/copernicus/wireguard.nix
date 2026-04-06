{ config, machines, ... }:
{
  age.secrets.copernicus-wg = {
    file = ../../secrets/copernicus.privkey.age;
  };
  age.secrets.thesus-copernicus-psk = {
    file = ../../secrets/thesus-copernicus.psk.age;
  };
  age.secrets.copernicus-hammurabi-psk = {
    file = ../../secrets/copernicus-hammurabi.psk.age;
  };
  
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "${machines.copernicus.ip-addrs.intnet}/32" ];
      privateKeyFile = config.age.secrets.copernicus-wg.path;

      peers = [
        {
          publicKey = machines.theseus.wg-pubkey;
          allowedIPs = [ "10.100.0.0/24" ];
          endpoint = "beepboop.systems:51820";
          presharedKeyFile = config.age.secrets.thesus-copernicus-psk.path;
          persistentKeepalive = 25;
        }
#        {
#          publicKey = machines.hammurabi.wg-pubkey;
#          allowedIPs = [ "${machines.hammurabi.ip-addrs.intnet}/32" ];
#          presharedKeyFile = config.age.secrets.copernicus-hammurabi-psk.path;
#        }
      ];
    };
  };
}
