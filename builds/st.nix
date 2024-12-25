{ stdenv
, lib
, fetchgit
, pkg-config
, libX11
, libXft
, fontconfig
, freetype
, ncurses
, fantasque-sans-mono
, lightMode ? false
, extraLibs ? [ ]
}:

stdenv.mkDerivation rec {
  pname = "st";
  version = "1.02";

  src = ./st;

  nativeBuildInputs = [ pkg-config fontconfig freetype ncurses ];
  buildInputs = [ libX11 libXft ] ++ extraLibs;

  buildPhase = lib.optionalString (lightMode == true) "cp lightmode.h colors.h;" +
  ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin
  '';

  meta = with lib; {
    description = "Customized builds of the st terminal emulator";
    homepage = "https://git.beepboop.systems/rndusr/st";
    license = licenses.mit;
  };
}
