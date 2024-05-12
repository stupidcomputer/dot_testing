{ stdenv
, lib
, pkgs
# shell scripts stuff
, makeWrapper
, sshuttle
, scrcpy
, sxhkd
, bash
, feh
, jq
, fzy
, figlet
, curl
, ytfzf
, herbe
, xrandr
, xrectsel
, ffcast
, svkbd
, xkbset
, rbw
, xclip
, libsForQt5
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.01";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash feh xrandr jq curl fzy ytfzf sshuttle svkbd scrcpy xkbset rbw xclip ffcast libsForQt5.kolourpaint ];

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/sh); do
      cp $src/sh/$i $out/bin
      ln -sf $out/bin/tmenu_run $out/bin/regenerate
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ sxhkd bash feh xrandr jq figlet curl fzy ytfzf herbe sshuttle svkbd scrcpy libsForQt5.kolourpaint xrectsel ffcast ]}
    done
  '';
}
