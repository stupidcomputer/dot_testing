{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdenlive
    inkscape
    gimp
    musescore
    bespokesynth
    audacity
    kdePackages.kdenlive
    texliveFull
  ];
}
