{ lib, config, pkgs, ...}:

{
  imports = [
    ./gnupg.nix
    ./fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    xscreensaver
    dunst
  ];

  services.xserver = {
    enable = true;
    xkb.layout = "us";

    displayManager.sx.enable = true;
  };

  services.libinput.enable = true;
}
