{ lib, config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    anki-bin
  ];
}
