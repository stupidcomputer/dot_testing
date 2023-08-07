{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
  ];

  environment.systemPackages = with pkgs; [
    xbrightness
  ];

  services.tlp.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xps";
}
