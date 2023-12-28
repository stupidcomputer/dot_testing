{ lib, inputs, config, pkgs, home, ... }:

{
  imports = [
    ./bash
    ./git
    ./htop
    ./nvim
    ./python
    ./gnupg

    ./tty-progs.nix
  ];

  home.stateVersion = "23.11";
}
