{ lib, config, pkgs, home, ... }:

{
  home.packages = [
    pkgs.elinks
  ];

  home.file = {
    ".config/elinks/elinks.conf" = {
      source = ../../.config/elinks/elinks.conf;
    };
  };
}
