{ lib, config, pkgs, ...}:

let
  customPolybar = pkgs.polybar.override {
    alsaSupport = true;
    pulseSupport = true;
  };
in {
  environment.systemPackages = with pkgs; [
    customPolybar
  ];
}
