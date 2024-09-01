{ lib, config, pkgs, home, ... }:

{
  home = {
    file = {
      ".config/xscreensaver/.xscreensaver" = {
        source = ../../.config/xscreensaver/.xscreensaver;
      };
    };
    packages = [
      pkgs.xscreensaver
    ];
  };
}
