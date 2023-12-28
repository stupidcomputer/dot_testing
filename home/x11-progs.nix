{ lib, config, pkgs, ...}:

{
  home.packages = with pkgs; [
    xclip
    xcape
    xscreensaver
    mpv
    feh
    xbrightness
    xdotool
  ];
}
