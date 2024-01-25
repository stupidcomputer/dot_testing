{ lib, config, pkgs, home, ... }:

{
  # if we use programs.bash.enable, it creates spurious .bashrc and .profile in
  # our home directory, which is no good
  home.packages = with pkgs; [
    bash
  ];

  home.file = {
    ".config/bash/bashrc" = {
      source = ./bashrc;
    };
    ".config/bash/profile" = {
      source = ./profile;
    };
  };
}
