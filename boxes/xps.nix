{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
    ../common/steam.nix
  ];

  environment.systemPackages = with pkgs; [
    xbrightness
    gnome.cheese
    musescore
    magic-wormhole
    libsForQt5.kdenlive
    calcurse
  ];

  services.tlp.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xps";
}
