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
, xmessage
, imagemagick
}:

stdenv.mkDerivation rec {
  pname = "utils";
  version = "1.01";

  src = ./utils;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash feh xrandr jq curl fzy ytfzf sshuttle svkbd scrcpy rbw xclip ffcast xkbset xmessage imagemagick ];

  installPhase = ''
    mkdir -p $out/bin

    for i in $(ls $src/); do
      cp $src/$i $out/bin
      wrapProgram $out/bin/$i --prefix PATH : ${lib.makeBinPath [ sxhkd bash feh xrandr jq figlet curl fzy xkbset ytfzf sshuttle svkbd scrcpy xrectsel ffcast xmessage imagemagick ]}
    done
  '';
}
