{ lib, config, pkgs, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ./server.nix
    ../../modules/bootstrap.nix
    ../../modules/common.nix
    ../../modules/x11.nix
    ../../modules/discord.nix
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
    vscodium-fhs
    libreoffice

    anki-bin
    ytfzf
    kdenlive
    libreoffice
    i3
    gcc
    gnumake

    scrcpy
    thunderbird
    mepo
  ];

  system.stateVersion = "23.11";
}
