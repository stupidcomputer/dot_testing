{ pkgs, machines, ... }:
{
  services.bind = {
    enable = true;
    listenOn = [ "any" ];
    forwarders = [ "1.1.1.1" "1.0.0.1" ];

    extraOptions = ''
      allow-query { any; };
      allow-recursion { cachenetworks; };
      recursion yes;
    '';

    cacheNetworks = [ "127.0.0.0/8" "10.100.0.0/24" ];

    zones = {
      "intnet.beepboop.systems" = {
        master = true;
        file = pkgs.writeText "intnet.beepboop.systems.zone" ''
          $ORIGIN intnet.beepboop.systems.
          $TTL 1h
          @ IN SOA ns1.intnet.beepboop.systems. admin.intnet.beepboop.systems. ( 1 3h 1h 1w 1h )
          @ IN NS ns1.intnet.beepboop.systems.

          @            IN A ${machines.theseus.ip-addrs.intnet}
          ns1          IN A ${machines.theseus.ip-addrs.intnet}
          theseus      IN A ${machines.theseus.ip-addrs.intnet}
          copernicus   IN A ${machines.copernicus.ip-addrs.intnet}
          hammurabi    IN A ${machines.hammurabi.ip-addrs.intnet}
        '';
      };
      "localnet.beepboop.systems" = {
        master = true;
        file = pkgs.writeText "localnet.beepboop.systems.zone" ''
          $ORIGIN localnet.beepboop.systems.
          $TTL 1h
          @ IN SOA ns1.localnet.beepboop.systems. admin.localnet.beepboop.systems. ( 1 3h 1h 1w 1h )
          @ IN NS ns1.localnet.beepboop.systems.

          ns1          IN A 10.100.0.1
          router       IN A ${machines.router.ip-addrs.localnet}
          copernicus   IN A ${machines.copernicus.ip-addrs.localnet}
          hue          IN A ${machines.hue.ip-addrs.localnet}
        '';
      };
      "0.100.10.in-addr.arpa" = {
        master = true;
        file = pkgs.writeText "0.100.10.rev" ''
          $ORIGIN 0.100.10.in-addr.arpa.
          $TTL 1h
          @ IN SOA ns1.intnet.beepboop.systems. admin.intnet.beepboop.systems. ( 1 3h 1h 1w 1h )
          @ IN NS ns1.intnet.beepboop.systems.

          1 IN PTR ns1.intnet.beepboop.systems.
        '';
      };
    };
  };

  networking.nameservers = [
    "10.100.0.1"
  ];
}
