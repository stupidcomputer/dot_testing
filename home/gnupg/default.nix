{ lib, config, pkgs, home, ... }:

{
  programs.gpg.enable = true;

  home.file = {
    ".local/share/gnupg/gpg-agent.conf" = {
      source = ./gpg-agent.conf;
    };
  };
}
