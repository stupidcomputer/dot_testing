{ lib, config, pkgs, home, ... }:

{
  programs.neovim.enable = true;

  home.file = {
    ".config/nvim/init.lua" = {
      source = ./init.lua;
    };
    ".config/nvim/colors/earth.vim" = {
      source = ./colors/earth.vim;
    };
  };
}
