{ lib, config, pkgs, ...}:

{
  programs.adb.enable = true;
  users.users.usr.extraGroups = [ "adbusers" ];
}
