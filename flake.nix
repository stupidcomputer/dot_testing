{
  description = "rndusr's nixos flake";

  inputs = {
    # regular nixos stuff
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    };
  };

  outputs = {
      self,
      nixpkgs,
      simple-nixos-mailserver,
      ...
    }@inputs: {
    nixosConfigurations = {
      netbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; } // { machines = import ./machines.nix; };
        modules = [
          ./boxes/netbox
          simple-nixos-mailserver.nixosModule
          {
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
        ];
      };
      copernicus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; } // { machines = import ./machines.nix; };
        modules = [
          ./boxes/copernicus
        ];
      };
      aristotle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; } // { machines = import ./machines.nix; };
        modules = [
          ./lappy/configuration.nix
        ];
      };
    };
  };
}
