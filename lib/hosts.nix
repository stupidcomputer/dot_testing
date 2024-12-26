{ lib, config, pkgs, inputs, ...}:

{
  networking.hosts = {
    "192.168.1.1" = [ "router" ];
    "192.168.1.200" = [ "mainsail" ];
    "192.168.1.201" = [ "x230t" ];
    "192.168.1.202" = [ "mlg" ];
    "192.168.1.203" = [ "phone" ];
    "149.28.63.115" = [ "netbox" ];
  };
}

