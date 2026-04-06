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

          @            IN A 10.100.0.1
          ns1          IN A 10.100.0.1
          theseus      IN A 10.100.0.1
          copernicus   IN A 10.100.0.2
          hammurabi    IN A 10.100.0.3
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
          router       IN A 192.168.1.1
          copernicus   IN A 192.168.1.201
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
