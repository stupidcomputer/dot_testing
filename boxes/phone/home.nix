{ lib, pkgs, home, ... }:
{
  imports = [
    ../../home/nvim
    ../../home/ssh
    ../../home/git # needed for flakes
    ../../home/vdirsyncer
    ../../home/isync
    ../../home/khal
    ../../home/todoman
    ../../home/msmtp
    ../../home/neomutt
    ../../home/rbw
    ./bash.nix
  ];

  home.stateVersion = "23.05";
}
