{
  description = "rndusr's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }@inputs: {
    nixosConfigurations = {
      virtbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./bootstrap.nix
          ./boxes/virtbox.nix
          ./common/desktop.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.usr = import ./home/terminal.nix;
          }
          nur.nixosModules.nur
        ];
      };
    };
  };
}
