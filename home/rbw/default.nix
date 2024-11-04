{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/rbw/config.json" = {
      source = ../../.config/rbw/config.json;
    };
  };
}
