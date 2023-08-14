{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
    ../common/steam.nix
  ];

  environment.systemPackages = with pkgs; [
    gnome.cheese
    musescore
    libsForQt5.kdenlive
  ];

  services.tlp.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xps";
}
