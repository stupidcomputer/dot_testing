{
  description = "rndusr's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      virtbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./bootstrap.nix
          ./boxes/virtbox.nix
	  ./common/desktop.nix
        ];
      };
    };
  };
}
