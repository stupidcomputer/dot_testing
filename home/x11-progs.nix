{ lib, config, pkgs, ...}:

{
  home.packages = with pkgs; [
    xclip
    xcape
    mpv
    sxiv
    xwallpaper
    xbrightness
    xdotool
  ];
}
