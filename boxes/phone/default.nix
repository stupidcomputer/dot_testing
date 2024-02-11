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
    vdirsyncer
    msmtp
    khal
    todoman
    neomutt
    khal
    git
    tmux
    hostname
  ];

  environment.etcBackupExtension = ".bak";
  system.stateVersion = "23.05";
  time.timeZone = "America/Chicago";
}
