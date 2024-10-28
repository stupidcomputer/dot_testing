{ lib, config, pkgs, ... }:
{
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        listenAddress = "10.100.0.1";
        port = 9002;
      };
    };
  };
}
