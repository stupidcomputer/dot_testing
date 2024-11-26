{ lib, config, pkgs, ...}:

{
  imports = [
    ./wireguard.nix
    ./nextcloud.nix
  ];
}
