{ lib, config, pkgs, ...}:

{
  services.xserver = {
    enable = true;
    xkb.layout = "us";

    displayManager.sx.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xorg.xset
    xorg.setxkbmap
    xcape
    xclip
  ];
}
