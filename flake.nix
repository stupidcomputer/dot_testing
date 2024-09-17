{
  description = "rndusr's nixos flake";

  inputs = {
    # regular nixos stuff
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    # nix-on-droid inputs
    phone-nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    home-manager-phone = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "phone-nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid/release-23.05";
      inputs.nixpkgs.follows = "phone-nixpkgs";
      inputs.home-manager.follows = "home-manager-phone";
    };
  };

  outputs = {
      self,
      nixpkgs,
      home-manager,
      firefox-addons,
      simple-nixos-mailserver,

      phone-nixpkgs,
      home-manager-phone,
      nix-on-droid,
      ...
    }@inputs: {
    nixOnDroidConfigurations = {
      phone = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          ./boxes/phone
        ];
      };
    };

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
      virtbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./boxes/virtbox

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.usr = import ./boxes/virtbox/home.nix;
          }
        ];
      };
      x230t = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./boxes/x230t

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.usr = import ./boxes/x230t/home.nix;
          }
        ];
      };
      aristotle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./boxes/aristotle

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.usr = import ./boxes/aristotle/home.nix;
          }
        ];
      };
      mainsail = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./boxes/mainsail
        ];
      };
    };
  };
}
