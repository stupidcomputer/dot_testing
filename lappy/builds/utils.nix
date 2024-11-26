{ stdenv
, lib
, pkgs
# shell scripts stuff
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.01";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/); do
      cp $src/$i $out/bin
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ ]}
    done
  '';
}
