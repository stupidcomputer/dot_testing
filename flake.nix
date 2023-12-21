{
  description = "rndusr's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    };
  };

  outputs = { self, nixpkgs, home-manager, firefox-addons, ... }@inputs: {
    nixosConfigurations = {
      virtbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        extraSpecialArgs = { inherit inputs; };
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
        ];
      };
    };
  };
}
