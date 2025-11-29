{
  description = "stupidcomputer's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
    }@inputs: let
      mkSystem = modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            machines = import ./lib/machines.nix;
          };
          inherit modules;
        };
      generateNixosConfigurations = configurations:
        builtins.listToAttrs (
          map (name: {
            inherit name;
            value = mkSystem [
              (./boxes/. + "/${name}")
              agenix.nixosModules.default
              {
                environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
              }
            ];
          }) configurations
        );
    in {
      nixosConfigurations = generateNixosConfigurations [ "netbox" "copernicus" "aristotle" "plato" ] // {
        hammurabi = nixpkgs.lib.nixosSystem {
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
              home-manager.users.usr.imports = [ ./boxes/hammurabi/home.nix ];
            }
          ];
        };
      };
    };
}
