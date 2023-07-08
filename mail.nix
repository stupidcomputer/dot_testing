{ config, pkgs, ... }:
let
  release = "nixos-23.05";
  cfg = config.services.nixosmail;
in {
  options.services.nixosmail = {
    enable = mkEnableOption "NixOS mail server";
  };

  imports = [
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      # This hash needs to be updated
      sha256 = "1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
    })
  ];

  config = mkIf cfg.enable {
    mailserver = {
      enable = true;
      fqdn = "mail.beepboop.systems";
      domains = [ "beepboop.systems" ];
      loginAccounts = {
        "ryan@beepboop.systems" = {
          # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt' > /hashed/password/file/location
          hashedPasswordFile = "/etc/ryan-beepboop-systemsuser-pass";

          aliases = [
              "info@beepboop.systems"
              "postmaster@beepboop.systems"
          ];
        };
      };
      certificateScheme = "acme-nginx";
    };
  };
}
