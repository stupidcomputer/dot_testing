{
  description = "stupidcomputer's nixos flake";

  inputs = {
    flagman = {
      url = "git+ssh://git@github.com/stupidcomputer/flagman.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
      self,

      agenix,
      flagman,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      ...
  }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    ppkgs = import ./ppkgs { inherit pkgs; };
    machines = import ./common/machines.nix;
  in {
      nixosConfigurations = {
        theseus = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs ppkgs machines;
          };
          modules = [
            ./boxes/theseus
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages."x86_64-linux".default ];
            }
          ];
        };
        copernicus = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs unstable ppkgs machines;
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
            }
          ];
        };
        hammurabi = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs ppkgs machines;
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
            }
          ];
        };
      };
    };
}
