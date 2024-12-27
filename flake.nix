{
  description = "stupidcomputer's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
      self,
      nixpkgs,
      simple-nixos-mailserver,
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
      nixosConfigurations = generateNixosConfigurations [ "netbox" "copernicus" "aristotle" ];
    };
}
