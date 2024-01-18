{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".local/share/pape.jpg" = {
      source = ./pape.jpg;
    };
  };
}
