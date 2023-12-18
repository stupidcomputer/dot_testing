{ lib, config, pkgs, ...}:
{
  imports = [
    ../common/steam.nix
    ../common/desktop.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "mainsail";

  services.paperless = {
    enable = true;
    passwordFile = "/etc/paperless-password";
    port = 3004;
    address = "localhost";
    extraConfig = {
      PAPERLESS_URL = "https://paperless.beepboop.systems";
    };
  };

  services.calibre-web.enable = true;
  services.calibre-web.listen.port = 8080;

  programs.adb.enable = true;
  users.users.usr.extraGroups = ["adbusers"];

  services.openssh = {
    enable = true;
    ports = [2222];
  };

  services.radicale = {
    enable = true;
    config = ''
      [auth]
      type = htpasswd
      htpasswd_filename = radicale-passwd
      htpasswd_encryption = plain
    '';
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

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

  systemd.services.paperless-web-bridge = {
    script = ''
      ${pkgs.openssh}/bin/ssh -v -NR 3004:localhost:3004 -p 55555 useracc@beepboop.systems
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "ankisyncd.service" ];
  };

  systemd.services.radicale-web-bridge = {
    script = ''
      ${pkgs.openssh}/bin/ssh -v -NR 5232:localhost:5232 -p 55555 useracc@beepboop.systems
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "ankisyncd.service" ];
  };

  systemd.services.internal-ssh-bridge = {
    script = ''
      ${pkgs.openssh}/bin/ssh -v -NR 2222:localhost:2222 -p 55555 useracc@beepboop.systems
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "ankisyncd.service" ];
  };
}
