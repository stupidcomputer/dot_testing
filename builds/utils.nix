{ stdenv
, lib
# for statusbar
, pkg-config
, libxcb
# shell scripts stuff
, makeWrapper
, sshuttle
, sxhkd
, bash
, feh
, jq
, ffmpeg
, fzy
, figlet
, curl
, ytfzf
, xrandr
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.01";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper pkg-config libxcb ];
  buildInputs = [ libxcb bash feh xrandr jq curl fzy ytfzf ffmpeg sshuttle ];

  buildPhase = ''
    ls
    make
  '';

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/sh); do
      cp $src/sh/$i $out/bin
      ln -sf $out/bin/tmenu_run $out/bin/regenerate
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ sxhkd bash feh xrandr jq figlet curl fzy ytfzf ffmpeg sshuttle ]}
    done

    cp c/status/main $out/bin/statusbar
  '';
}
