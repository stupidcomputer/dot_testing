{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hueadm
  ];
}
