{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    inkscape
    gimp
    musescore
    bespokesynth
    audacity
    kdePackages.kdenlive
    texliveFull
  ];
}
