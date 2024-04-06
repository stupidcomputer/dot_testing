{ lib, config, pkgs, ...}:

let
  plib = import ../lib { inherit pkgs; };
in {
  home.packages = [
    pkgs.xclip
    pkgs.xcape
    pkgs.xscreensaver
    pkgs.mpv
    pkgs.sxiv
    pkgs.xwallpaper
    pkgs.xbrightness
    pkgs.xdotool
  ] ++ [
    (plib.mkPackageWrapper
      pkgs.brave
      "export HOME=$HOME/.cache/brave"
      ""
      "--args --disable-frame-rate-limit"
    )
  ];
}
