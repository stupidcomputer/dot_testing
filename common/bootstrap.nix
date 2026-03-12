# make the nixos environment amenable to flakes
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    neovim

    # don't replace with ppkgs construction, as this config needs to function
    # without flakes
    (pkgs.callPackage ../ppkgs/rebuild.nix {})
  ];

  nix.settings = {
    warn-dirty = false;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config.allowUnfree = true;
}
