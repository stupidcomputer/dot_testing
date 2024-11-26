{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ./utils.nix {})
    (callPackage ./dwm.nix {})
  ];
}
