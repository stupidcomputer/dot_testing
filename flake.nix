{
  description = "stupidcomputer's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
      self,
      nixpkgs,
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
          ];
        };
        aristotle = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            machines = import ./lib/machines.nix;
          };
          modules = [
            ./boxes/aristotle
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
            }
          ];
        };
        plato = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            machines = import ./lib/machines.nix;
          };
          modules = [
            ./boxes/plato
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
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
          ];
        };
      };
    };
}
