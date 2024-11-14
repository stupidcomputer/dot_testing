{ lib, config, pkgs, ...}:

{
  imports = [
    ./wireguard.nix
    ./grafana.nix
    ./nextcloud.nix
    ./paperless.nix
  ];
}
