{ lib, config, pkgs, ...}:

{
  imports = [
    ./gnupg.nix
    ./fonts.nix
    ./pulse.nix
    ./sxiv.nix
  ];

  environment.systemPackages = with pkgs; [
    bspwm
    sxhkd
    xscreensaver
  ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    layout = "us";

    displayManager.sx.enable = true;
  };
}
