{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    prismlauncher
    xonotic
  ];

  programs.steam.enable = true;
}
