{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/neomutt/neomuttrc" = {
      source = ./neomuttrc;
    };
  };
}
