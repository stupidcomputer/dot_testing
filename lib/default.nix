{ pkgs ? import <nixpkgs> {} }:
let
  getPkgName =
    pkg:
    builtins.elemAt (builtins.split "-" pkg.name) 0;
in {
  mkPackageWrapper =
    pkg:
    environ:
    prefix:
    postfix:
    pkgs.writeScriptBin
      (getPkgName pkg)
      ''
        #! ${pkgs.bash}/bin/bash
        ${environ}
        exec ${prefix} ${pkg}/bin/${getPkgName pkg} ${postfix} "$@"
      '';
  mkQuarantinedPackage =
    pkg:
    pkgs.writeScriptBin
      (getPkgName pkg)
      ''
        #! ${pkgs.bash}/bin/bash
        export HOME=$HOME/.local/${getPkgName pkg}
        exec ${pkg}/bin/${getPkgName pkg}
      '';
}
