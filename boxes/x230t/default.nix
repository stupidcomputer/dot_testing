{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/tlp.nix
    ../../modules/media.nix
    ../../modules/anki.nix
    ../../modules/power-control.nix
    ../../modules/adb.nix
  ];

  environment.systemPackages = with pkgs; [
    xscreensaver
    thunderbird
    hue-cli
  ];

  hardware.bluetooth = {
    enable = true;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event[0-20]*", ENV{ID_INPUT_TOUCHSCREEN}=="1", MODE:="0666" GROUP="usr", SYMLINK+="input/touchscreen"
  '';

  users.users.usr.extraGroups = [ "input" ];

  services.getty.autologinUser = "usr";

  boot.loader = {
    grub.timeoutStyle = "hidden";
    timeout = 0;
    grub.enable = true;
    grub.device = "/dev/sda";
  };

  hardware.pulseaudio.enable = true;


  networking.hostName = "x230t";

  system.stateVersion = "23.11";
}
