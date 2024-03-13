{ lib, config, pkgs, ...}:

{
  imports = [
    ./gnupg.nix
    ./fonts.nix
    ./pulse.nix
  ];

  environment.systemPackages = with pkgs; [
    xscreensaver
  ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    layout = "us";

    displayManager.sx.enable = true;
  };
}
