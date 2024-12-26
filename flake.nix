{
  description = "rndusr's nixos flake";

  inputs = {
    # regular nixos stuff
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    };
  };

  outputs = {
      self,
      nixpkgs,
      simple-nixos-mailserver,
      ...
    }@inputs: {
    nixosConfigurations = {
      netbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; } // { machines = import ./machines.nix; };
        modules = [
          ./boxes/netbox
        ];
      };
      copernicus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; } // { machines = import ./machines.nix; };
        modules = [
          ./boxes/copernicus
        ];
      };
      aristotle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; } // { machines = import ./machines.nix; };
        modules = [
          ./lappy/configuration.nix
        ];
      };
    };
  };
}
