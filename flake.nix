{
  description = "stupidcomputer's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
      self,
      nixpkgs,
      home-manager,
      agenix,
      ...
    }@inputs: {
      nixosConfigurations = {
        netbox = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            machines = import ./lib/machines.nix;
          };
          modules = [
            ./boxes/netbox
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
            }
          ];
        };
        copernicus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            machines = import ./lib/machines.nix;
          };
          modules = [
            ./boxes/copernicus
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.usr = import ./boxes/copernicus/home.nix;
            }
          ];
        };
        hammurabi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            machines = import ./lib/machines.nix;
          };
          modules = [
            ./boxes/hammurabi
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.usr = import ./boxes/hammurabi/home.nix;
            }
          ];
        };
      };
    };
}
