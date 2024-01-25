{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    neovim
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
