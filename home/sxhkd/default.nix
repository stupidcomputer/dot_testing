{ lib, config, pkgs, home, ... }:

{
  # managed by nixos configuration
  home.packages = with pkgs; [
    sxhkd
  ];

  home.file = {
    ".config/sxhkd/sxhkdrc" = {
      source = ../../.config/sxhkd/sxhkdrc;
    };
    ".config/sxhkd/mouse" = {
      source = ../../.config/sxhkd/mouse;
    };
  };
}
