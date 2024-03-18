{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/nws" = {
      text = ''KOHX'';
    };
  };
}
