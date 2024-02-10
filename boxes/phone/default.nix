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

  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have

    git
    tmux
    hostname
  ];

  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.05";

  # Set your time zone
  time.timeZone = "America/Chicago";
}
