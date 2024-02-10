{ lib, pkgs, home, ... }:
{
  imports = [
    ../../home/nvim
    ../../home/ssh
    ../../home/git # needed for flakes
  ];

  home.stateVersion = "23.05";
}
