{ lib, config, pkgs, inputs, ...}:

{
  networking.hosts = {
    "192.168.1.120" = [ "x230t" ];
    "192.168.1.52" = [ "mlg" ];
    "192.168.1.100" = [ "mainsail" ];
  };
}

