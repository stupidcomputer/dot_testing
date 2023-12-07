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

  programs.adb.enable = true;
  users.users.usr.extraGroups = ["adbusers"];

  services.radicale = {
    enable = true;
    config = ''
      [auth]
      type = htpasswd
      htpasswd_filename = radicale-passwd
      htpasswd_encryption = plain
    '';
  };

  environment.etc."nextcloud-admin-pass".text = "aslkfjaslkdfjsalkdfjlKJFLKJDLFKJLSKDJFLSKDJFLSKDJFLSKDFJ";
  services.nextcloud = {
    enable = true;
    hostName = "beepboop.systems";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    package = pkgs.nextcloud27;
    # Instead of using pkgs.nextcloud27Packages.apps,
    # we'll reference the package version specified above
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit news contacts calendar tasks;
    };
    extraAppsEnable = true;
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

    anki
    ytfzf
    kdenlive
    libreoffice
    i3
    gcc
    gnumake

    scrcpy
  ];

  systemd.services.paperless-activate = {
    script = ''
      while true; do
        # restart every 5 minutes
        echo "starting link"
        ${pkgs.openssh}/bin/ssh -v -NR 3004:localhost:3004 -p 55555 useracc@beepboop.systems &
        ONE="$!"
        ${pkgs.openssh}/bin/ssh -v -NR 4000:localhost:80 -p 55555 useracc@beepboop.systems &
        TWO="$!"
        ${pkgs.openssh}/bin/ssh -v -NR 5232:localhost:5232 -p 55555 useracc@beepboop.systems &
        THREE="$!"
        echo "waiting"
        sleep $((60 * 5))
        echo "killing and restarting"
        kill $ONE || true
        kill $TWO || true
        kill $THREE || true
      done
    '';

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "ankisyncd.service" ];
  };
}
