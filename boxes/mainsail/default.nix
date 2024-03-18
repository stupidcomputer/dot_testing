{ lib, config, pkgs, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/ssh-phone-home.nix
    ../../modules/bootstrap.nix
    ../../modules/hosts.nix
    ../../modules/common.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "mainsail";

  services.getty.greetingLine = "
    welcome to mainsail    |`-:_
  ,----....____            |    `+.
 (             ````----....|___   |
  \\     _                      ````----....____
   \\    _)                                     ```---.._
    \\                                                   \\
  )`.\\  )`.   )`.   )`.   )`.   )`.   )`.   )`.   )`.   )`.   )`.
-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `-'   `
  ";

  environment.systemPackages = with pkgs; [
    neovim
    git
    curl
  ];

  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "netgear"
      "hue"
      "nest"
      "esphome"
      "met"
      "radio_browser"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
    openFirewall = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.ssh-phone-home = {
    enable = true;
    localUser = "usr";
    remoteHostname = "beepboop.systems";
    remotePort = 443;
    remoteUser = "ryan";
    bindPort = 55554;
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbhM3wj0oqjR3pUaZgpfX4Xo4dlzvBTbQ48zHyg7Pwx usr" # x230t
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2xUbQw9+RCPVw7qCFm4NNCP/MpS2BIArcwMv0KdKOI usr" # mlg
  ];

  system.stateVersion = "23.11";
}
