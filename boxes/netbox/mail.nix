{ inputs, ...}:
{
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

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
      "machines@beepboop.systems" = {
        hashedPasswordFile = "/etc/ryan-beepboop-systemsuser-pass";
      };
    };
    certificateScheme = "acme-nginx";
  };
}
