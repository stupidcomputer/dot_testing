{
  description = "rndusr's nixos flake";

  inputs = {
    # regular nixos stuff
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    };
  };

  outputs = {
      self,
      nixpkgs,
      home-manager,
      simple-nixos-mailserver,
      ...
    }@inputs: {
    nixosConfigurations = {
      netbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
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
      mlg = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./boxes/mlg

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.usr = import ./boxes/mlg/home.nix;
          }
        ];
      };
      copernicus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./boxes/copernicus

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.usr = import ./boxes/copernicus/home.nix;
          }
        ];
      };
      aristotle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./lappy/configuration.nix
        ];
      };
    };
  };
}
