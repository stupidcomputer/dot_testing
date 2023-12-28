{ lib, config, pkgs, ...}:

{
  imports = [
    ./polybar.nix
    ./gnupg.nix
    ./fonts.nix
    ./pulse.nix
  ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    layout = "us";

    displayManager.sx.enable = true;
  };
}
