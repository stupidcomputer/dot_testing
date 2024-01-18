{ lib, config, pkgs, ...}:

{
  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];
}
