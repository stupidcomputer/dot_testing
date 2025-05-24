{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdenlive
    inkscape
    gimp
    musescore
  ];
}
