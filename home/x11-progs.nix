{ lib, config, pkgs, ...}:

let
  plib = import ../lib { inherit pkgs; };
in {
  home.packages = [
    pkgs.xclip
    pkgs.xcape
    pkgs.mpv
    pkgs.sxiv
    pkgs.xwallpaper
    pkgs.xbrightness
    pkgs.xdotool
  ];
}
