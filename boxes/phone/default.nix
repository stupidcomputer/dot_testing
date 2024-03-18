{ config, lib, pkgs, ... }:

{
  imports = [
    ./bootstrap.nix
  ];

  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;

    config = ./home.nix;
  };

  environment.packages = with pkgs; [
    tigervnc
    git
    tmux
    hostname
    tigervnc
    xorg.xinit
#    tar
#    awk
#    sed
    elinks
  ];

  environment.etcBackupExtension = ".bak";
  system.stateVersion = "23.05";
  time.timeZone = "America/Chicago";
}
