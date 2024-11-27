{ stdenv
, lib
, pkgs
# shell scripts stuff
, makeWrapper
, xclip
, rbw
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.01";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ xclip rbw ];

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/); do
      cp $src/$i $out/bin
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ xclip rbw ]}
    done
  '';
}
