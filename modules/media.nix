{ lib, config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    musescore
    audacity
    libsForQt5.kdenlive
    anki-bin
  ];
}
