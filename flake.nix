{
  description = "rndusr's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utilpkg = {
      url = "./builds";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-23.11";
  };

  outputs = { self, nixpkgs, home-manager, firefox-addons, simple-nixos-mailserver, utilpkg, ... }@inputs: {
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
	      };
              certificateScheme = "acme-nginx";
	    };
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
      mainsail = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./boxes/mainsail

          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.usr = import ./boxes/mainsail/home.nix;
          }
        ];
      };
    };
  };
}
