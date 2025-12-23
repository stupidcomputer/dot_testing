{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.programs.i3pystatus;
in {
  options.programs.i3pystatus = {
    enable = mkEnableOption "i3pystatus";
    configuration = mkOption {
      description = "Contents of configuration file.";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.i3pystatus ];
    xdg.configFile."i3pystatus/config.py".text = cfg.configuration;
  };
}
