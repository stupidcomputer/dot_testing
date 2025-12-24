# make the nixos environment amenable to flakes
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    neovim

    (pkgs.callPackage ../builds/rebuild.nix {})
  ];

  nix.settings = {
    warn-dirty = false;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;
}
