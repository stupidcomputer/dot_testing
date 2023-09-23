{ stdenv
, lib
, bash
, gnupg
, makeWrapper
, fetchgit
}:

stdenv.mkDerivation rec {
  pname = "pash";
  version = "1.00";

  src = fetchgit {
    url = "https://git.beepboop.systems/rndusr/pash";
    sha256 = "sha256-0L3N7F4BwVdu4rR5xpUEIHcX/x64Gni8JTUki5kGH24=";
  };

  nativeBuildInputs = [ makeWrapper gnupg ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/pash $out/bin/pash
    wrapProgram $out/bin/pash --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';

  phases = [ "installPhase" ];
}
