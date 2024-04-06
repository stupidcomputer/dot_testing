{ lib, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    neomutt
  ];

  home.file = {
    ".config/neomutt/neomuttrc" = {
      source = ../../.config/neomutt/neomuttrc;
    };
  };
}
