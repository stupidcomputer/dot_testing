{ lib, config, pkgs, home, ... }:

{
  home.file = {
    ".config/dunst/dunstrc" = {
      source = ../../.config/dunst/dunstrc;
    };
    ".config/dunst/notification_handler.sh" = {
      source = ../../.config/dunst/notification_handler.sh;
    };
    ".config/dunst/beep.m4a" = {
      source = ../../.config/dunst/beep.m4a;
    };
  };
}
