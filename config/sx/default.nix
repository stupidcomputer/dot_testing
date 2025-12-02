{ pkgs, ...}:
{
  services.xserver = {
    enable = true;
    xkb.layout = "us";

    displayManager.sx.enable = true;
  };

  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];

  environment.systemPackages = with pkgs; [
    # generic x11 utilities
    xorg.xset
    xorg.setxkbmap
    xcape
    xclip
    x11vnc
    xwallpaper
    xdotool
    tigervnc

    feh
    picom
    arandr

    mpv
    sxiv
    scrcpy
  ];

  system.userActivationScripts.copySxConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/sx
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/sx/aristotle /home/usr/.config/sx/sxrc
    '';
    deps = [];
  };
}
