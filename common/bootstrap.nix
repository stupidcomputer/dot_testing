{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    neovim

    (pkgs.callPackage ../builds/rebuild.nix {})
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
