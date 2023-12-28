{ lib, config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    discord
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
  ];
}
