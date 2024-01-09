{ lib, config, pkgs, ...}:

{
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.extraUsers.usr.extraGroups = [ "audio" ];
}
