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
, xrandr
, xrectsel
, ffcast
, svkbd
, xkbset
, rbw
, xclip
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.01";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash feh xrandr jq curl fzy ytfzf sshuttle svkbd scrcpy rbw xclip ffcast xkbset ];

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/sh); do
      cp $src/sh/$i $out/bin
      ln -sf $out/bin/tmenu_run $out/bin/regenerate
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ sxhkd bash feh xrandr jq figlet curl fzy xkbset ytfzf sshuttle svkbd scrcpy xrectsel ffcast ]}
    done
  '';
}
