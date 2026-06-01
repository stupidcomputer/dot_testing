{
  description = "stupidcomputer's nixos flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
      self,

      agenix,
      firefox-addons,
      flagman,
      home-manager,
      llm-agents,
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
