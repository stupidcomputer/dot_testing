{ lib, config, pkgs, ...}:

{
  imports = [
    ./wireguard.nix
    ./sshd.nix
  ];
}
