{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      withSystem =
        f:
        lib.fold lib.recursiveUpdate { } (
          map f [
            "x86_64-linux"
          ]
        );
      mkPackages = pkgs: {
        st = pkgs.callPackage ./st.nix { };
        rebuild = pkgs.callPackage ./rebuild.nix { };
        utils = pkgs.callPackage ./utils.nix { };
      };
    in
    withSystem (
      system: {
        overlays.default = final: _: mkPackages final;

        packages.${system} = mkPackages nixpkgs.legacyPackages.${system};
      }
    );
}
