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
    xdotool
    texlive.combined.scheme-full
    zathura
  ];

  services.tlp.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  networking.hostName = "xps";
}
