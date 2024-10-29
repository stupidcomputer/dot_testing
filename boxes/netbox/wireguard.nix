{ lib, config, pkgs, ... }:

{
  networking = {
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
    };
    firewall.allowedUDPPorts = [ 51820 ];

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];

        listenPort = 51820;

        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';

        privateKeyFile = "/home/ryan/wg-keys/private";

        peers = [
          { # copernicus
            publicKey = "JlH1X4KRT+B8Uau+qTLtBqyapkbGClIj1db7znU77kc=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
          { # aristotle
            publicKey = "Sw2yyMhyS8GOCWm1VuGn3Y7cfx606dXOGK5mux8ckQU=";
            allowedIPs = [ "10.100.0.3/32" ];
          }
        ];
      };
    };
  };
}
