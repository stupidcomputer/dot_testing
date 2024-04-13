{ lib, config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ./special-ssh-magic.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/hosts.nix
    ../../modules/tlp.nix
    ../../modules/media.nix
    ../../modules/anki.nix
    ../../modules/power-control.nix
    ../../modules/adb.nix
    ../../modules/rbw.nix
  ];

  environment.systemPackages = with pkgs; [
    xscreensaver
    texliveFull
    libreoffice

    ecryptfs
    ffmpeg
    thunderbird
    ledger
  ];

  hardware.bluetooth = {
    enable = true;
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event[0-20]*", ENV{ID_INPUT_TOUCHSCREEN}=="1", MODE:="0666" GROUP="usr", SYMLINK+="input/touchscreen"
  '';

  users.users.usr.extraGroups = [ "input" ];

  services.getty.autologinUser = "usr";

  boot.loader = {
    grub = {
      timeoutStyle = "hidden";
      enable = true;
      device = "/dev/sda";
      splashImage = null;
    };
    timeout = 1;
  };

  hardware.pulseaudio.enable = true;


  networking.hostName = "x230t";

  system.stateVersion = "23.11";
}
