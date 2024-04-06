{ lib, config, pkgs, home, ... }:

{
  home.packages = [
    (pkgs.callPackage ./elinks.nix {})
  ];

  home.file = {
    ".config/elinks/elinks.conf" = {
      source = ../../.config/elinks/elinks.conf;
    };
  };
}
