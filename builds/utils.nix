{ stdenv
, lib
, bash
, feh
, jq
, curl
, xrandr
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.00";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash feh xrandr jq curl ];

  buildPhase = "";

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/sh); do
      cp $src/sh/$i $out/bin
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ bash feh xrandr jq curl ]}
    done
  '';

  phases = [ "buildPhase" "installPhase" ];
}
