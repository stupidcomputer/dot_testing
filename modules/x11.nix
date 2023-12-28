{ lib, config, pkgs, ...}:

{
  imports = [
    ./polybar.nix
    ./gnupg.nix
    ./fonts.nix
    ./pulse.nix
  ];

  environment.systemPackages = [
    pkgs.bspwm
    pkgs.sxhkd
  ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    layout = "us";

    displayManager.sx.enable = true;
  };
}
