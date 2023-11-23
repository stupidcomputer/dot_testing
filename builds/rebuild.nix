{ stdenv
, lib
, bash
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "rebuild";
  version = "1.00";

  src = ./rebuild;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  buildPhase = "";

  installPhase = ''
    mkdir -p $out/bin
    cp $src/rebuild $out/bin
    wrapProgram $out/bin/rebuild --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';

  phases = [ "buildPhase" "installPhase" ];
}

