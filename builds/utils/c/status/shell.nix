with import <nixpkgs> {};
 pkgs.mkShell {
   nativeBuildInputs = [
    gdb
    gnumake
    pkg-config
    xorg.libxcb
   ];
 }
