{ lib, config, pkgs, home, ... }:

{
  programs.neovim.enable = true;

  home.packages = with pkgs; [
    lua-language-server
    texlab
    pylyzer
  ];

  home.file = {
    ".config/nvim/init.lua" = {
      source = ../../.config/nvim/init.lua;
    };
    ".config/nvim/colors/earth.vim" = {
      source = ../../.config/nvim/colors/earth.vim;
    };
  };
}
