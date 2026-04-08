{ lib, stdenv, fetchurl, libX11, libXinerama, libXft, zlib }:

stdenv.mkDerivation rec {
  pname = "stupid-dmenu";
  version = "5.2";

  src = builtins.fetchGit {
    url = "https://github.com/stupidcomputer/dmenu.git";
    rev = "21404c3688a9bb6904e8924c757e8ea22ca2a219";
  };

  buildInputs = [ libX11 libXinerama zlib libXft ];

  postPatch = ''
    sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
    sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
  '';

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  makeFlags = [ "CC:=$(CC)" ];
}
