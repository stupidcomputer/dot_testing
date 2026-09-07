{ config, pkgs, machines, ... }:
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

      postUp = ''
        ${pkgs.systemd}/bin/resolvectl dns wg0 10.100.0.1
        ${pkgs.systemd}/bin/resolvectl domain wg0 "~intnet.beepboop.systems" "~localnet.beepboop.systems"
      '';
      preDown = ''
        ${pkgs.systemd}/bin/resolvectl revert wg0
      '';

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
