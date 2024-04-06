{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/tridactyl/tridactylrc" = {
      source = ../../.config/tridactyl/tridactylrc;
    };
  };
}
