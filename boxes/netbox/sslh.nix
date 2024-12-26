{ lib, config, pkgs, ... }:
{
  services.sslh = {
    enable = true;
    settings = {
        protocols = [
        {
          host = "localhost";
          name = "ssh";
          port = "55555";
          service = "ssh";
        }
        {
          host = "localhost";
            name = "tls";
            port = "442";
        }
      ];
      transparent = true;
    };
  };
}
