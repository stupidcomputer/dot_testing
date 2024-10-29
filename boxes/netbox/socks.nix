{ lib, config, pkgs, ... }:
{
  services._3proxy = {
    enable = true;
    services = [
      {
        type = "socks";
        auth = [ "none" ];
        bindAddress = "10.100.0.1";
        bindPort = 3128;
      }
    ];
  };
}
