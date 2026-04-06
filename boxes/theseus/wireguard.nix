{ config, machines, ... }:
let
  wgListenPort = 51820;
in {
  age.secrets.theseus-wg = {
    file = ../../secrets/theseus.privkey.age;
  };
  age.secrets.thesus-copernicus-psk = {
    file = ../../secrets/thesus-copernicus.psk.age;
  };
  age.secrets.hammurabi-thesus-psk = {
    file = ../../secrets/hammurabi-thesus.psk.age;
  };

  networking.firewall = {
    allowedUDPPorts = [ wgListenPort ];
    trustedInterfaces = [ "wg0" ];
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "${machines.theseus.ip-addrs.intnet}/32" ];
    listenPort = wgListenPort;
    privateKeyFile = config.age.secrets.theseus-wg.path;
    peers = [
      {
        publicKey = machines.copernicus.wg-pubkey;
        allowedIPs = [ "${machines.copernicus.ip-addrs.intnet}/32" ];
        presharedKeyFile = config.age.secrets.thesus-copernicus-psk.path;
      }
      {
        publicKey = machines.hammurabi.wg-pubkey;
        allowedIPs = [ "${machines.hammurabi.ip-addrs.intnet}/32" ];
        presharedKeyFile = config.age.secrets.hammurabi-thesus-psk.path;
      }
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.extraCommands = ''
    iptables -A FORWARD -i wg0 -o wg0 -j ACCEPT
  '';
}
