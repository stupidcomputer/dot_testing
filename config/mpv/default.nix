{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mpv
  ];
}
