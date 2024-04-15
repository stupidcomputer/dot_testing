{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ./bash
    ./git
    ./htop
    ./nvim
    ./python
    ./gnupg
    ./elinks
    ./ssh

    ./tty-progs.nix
  ];
}
