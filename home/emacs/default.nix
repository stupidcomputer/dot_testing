{ lib, config, pkgs, home, ... }:

{
  programs.emacs.enable = true;

  home.file = {
    ".config/emacs/init.el" = {
      source = ../../.config/emacs/init.el;
    };
  };
}
