{ lib, inputs, config, pkgs, home, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "ecnphlgnajanjnkcmbpancdjoidceilk"; }
    ];
  };
}
