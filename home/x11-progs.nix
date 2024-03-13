{ lib, config, pkgs, ...}:

{
  home.packages = with pkgs; [
    xclip
    xcape
    xscreensaver
    mpv
    sxiv
    xwallpaper
    xbrightness
    xdotool

    brave
  ];
}
