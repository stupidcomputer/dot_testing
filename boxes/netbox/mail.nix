{ config, inputs, ... }:
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
        hashedPasswordFile = config.age.secrets.mailaccount.path;

        aliases = [
            "info@beepboop.systems"
            "postmaster@beepboop.systems"
        ];
      };
    };
    certificateScheme = "acme-nginx";
  };
}
