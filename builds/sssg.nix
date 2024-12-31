{ stdenv
, lib
, fetchgit
, makeWrapper
, bash
, pandoc
}:

stdenv.mkDerivation rec {
  pname = "sssg";
  version = "1.00";

  src = fetchgit {
    url = "https://git.beepboop.systems/stupidcomputer/sssg";
    hash = "sha256-b0lbHsu628CKPNC6HDLApZQ4HsinTrXCoFqr1KdVIYE=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash pandoc ];

  installPhase = ''
    mkdir -p $out/bin

    cp $src/sssg.sh $out/bin/sssg
    wrapProgram $out/bin/sssg --prefix PATH : ${lib.makeBinPath [ bash pandoc ]}
  '';
}
