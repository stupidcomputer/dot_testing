{
  description = "stupidcomputer's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
      self,
      nixpkgs,
      simple-nixos-mailserver,
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
            value = mkSystem [ (./boxes/. + "/${name}") ];
          }) configurations
        );
    in {
      nixosConfigurations = generateNixosConfigurations [ "netbox" "copernicus" "aristotle" ];
    };
}
