{ pkgs, ppkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix
    ../../common/bootstrap.nix
    ./agenix.nix
    ./sshd.nix
  ];

  services.ryande.enable = true;

  environment.systemPackages = with pkgs; [
    ppkgs.tilp
    anki-bin
    sshuttle
    vscode
    styluslabs-write
  ];

  programs.steam.enable = true;

  services = {
    power-profiles-daemon.enable = true;
    ntp.enable = true;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv4.tcp_ecn" = 0;
    };
  };

  networking = {
    hostName = "hammurabi";
    networkmanager.enable = true;
    firewall.checkReversePath = false;
  };

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  # don't touch these
  system.stateVersion = "25.05";
  home-manager.users.usr.home.stateVersion = "25.05";
}
