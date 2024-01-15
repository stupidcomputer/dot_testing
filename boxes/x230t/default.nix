{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/tlp.nix
    ../../modules/media.nix
    ../../modules/anki.nix
    ../../modules/power-control.nix
  ];

  environment.systemPackages = with pkgs; [
    xscreensaver
  ];

  services.getty.autologinUser = "usr";

  boot.loader = {
    grub.timeoutStyle = "hidden";
    timeout = 0;
    grub.enable = true;
    grub.device = "/dev/sda";
  };

  hardware.pulseaudio.enable = true;


  networking.hostName = "x230t";

  system.stateVersion = "23.11";
}
