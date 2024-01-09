{ lib, inputs, config, pkgs, home, ... }:

{
  home.packages = with pkgs; [
    ungoogled-chromium
  ];

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };
}
