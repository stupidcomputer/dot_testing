{ stdenv
, lib
# for statusbar
, pkg-config
, libxcb
# shell scripts stuff
, makeWrapper
, sshuttle
, scrcpy
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
, svkbd
, libsForQt5
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.01";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper pkg-config libxcb ];
  buildInputs = [ libxcb bash feh xrandr jq curl fzy ytfzf ffmpeg sshuttle svkbd scrcpy libsForQt5.kolourpaint ];

  buildPhase = ''
    ls
    make
  '';

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/sh); do
      cp $src/sh/$i $out/bin
      ln -sf $out/bin/tmenu_run $out/bin/regenerate
<<<<<<< HEAD
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ sxhkd bash feh xrandr jq figlet curl fzy ytfzf ffmpeg sshuttle scrcpy ]}
=======
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ sxhkd bash feh xrandr jq figlet curl fzy ytfzf ffmpeg sshuttle svkbd libsForQt5.kolourpaint ]}
>>>>>>> f481fd5f3f58fe7ac42fb5d07703be8d59fb4502
    done

    cp c/status/main $out/bin/statusbar
  '';
}
