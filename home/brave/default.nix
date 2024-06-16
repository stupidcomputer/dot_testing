{ lib, inputs, config, pkgs, home, ... }:

let
  plib = import ../../lib { inherit pkgs; };
in {
  programs.chromium = {
    enable = true;
    package = lib.mkForce (plib.mkPackageWrapper
      pkgs.brave
      "export HOME=$HOME/.cache/brave"
      ""
      "--args --disable-frame-rate-limit"
    );
    extensions = [
      { id = "ecnphlgnajanjnkcmbpancdjoidceilk"; }
    ];
  };
}
