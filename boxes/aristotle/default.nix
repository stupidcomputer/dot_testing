{ pkgs, lib, machines, ... }:
{
  imports = [
    ../../config/aristotle.nix
    ./paperless.nix
    ./sshd.nix
    ./agenix.nix
    ./hardware-configuration.nix
  ];

  programs.adb.enable = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
  };

  networking = {
    hostName = "aristotle";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 24800 ];

    hosts = lib.attrsets.mergeAttrsList [
      (machines.mkHosts machines "router" "localnet")
      (machines.mkHosts machines "copernicus" "localnet")
      (machines.mkHosts machines "phone" "localnet")
      (machines.mkHosts machines "netbox" "internet")
    ] // {
      "127.0.0.1" = [ "news.ycombinator.com" ];
    };
  };
  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "bredr";
    };
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.usr = {
    isNormalUser = true;
    description = "usr";
    extraGroups = [ "networkmanager" "wheel" "input" "adbusers" ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    libinput.enable = true;
    tlp.enable = true;
  };

  powerManagement.powertop.enable = true;

  systemd.services."getty@tty6" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = ["" "@${pkgs.coreutils}/bin/cat"];
  };

  systemd.user.services.ssh-socks5-proxy = {
    enable = true;
    description = "SOCKS5 proxy over ssh";

    serviceConfig.ExecStart = "${pkgs.openssh}/bin/ssh -ND 127.0.0.1:4000 netbox";
    wantedBy = []; # start only when I say so
  };

  systemd.services.syncthing = {
    enable = true;
    description = "start syncthing on network startup";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.syncthing}/bin/syncthing";
      User = "usr";
      Restart = "on-failure";
      RestartSec = "3";
    };
  };

  system.stateVersion = "24.05";
}
