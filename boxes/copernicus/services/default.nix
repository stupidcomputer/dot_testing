{ lib, config, pkgs, ...}:

{
  imports = [
    ./photoprism.nix
    ./wireguard.nix
  ];
}
