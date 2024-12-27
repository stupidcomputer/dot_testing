{ stdenv
, lib
, pkgs
# shell scripts stuff
, makeWrapper
, kbd # for chvt
, xclip
, rbw
}:

stdenv.mkDerivation rec {
  pname = "lappy-utils";
  version = "1.01";

  src = ./lappy-utils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ xclip kbd rbw ];

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/); do
      cp $src/$i $out/bin
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ xclip kbd rbw ]}
    done
  '';
}
