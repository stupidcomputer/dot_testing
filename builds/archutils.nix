{ stdenv
, lib
, pkgs
, makeWrapper
, sxhkd
, bash
, feh
, jq
, fzy
, curl
, texliveFull
}:

stdenv.mkDerivation rec {
  pname = "archutils";
  version = "1.01";

  src = ./archutils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    bash
    feh
    jq
    curl
    fzy
    texliveFull
  ];

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/); do
      cp $src/$i $out/bin
      ln -sf $out/bin/tmenu_run $out/bin/regenerate
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ bash feh jq curl fzy texliveFull ]}
    done
  '';
}
