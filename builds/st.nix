{ stdenv
, lib
, pkg-config
, libX11
, libXft
, fontconfig
, freetype
, ncurses
, lightMode ? false
, aristotle ? false
, extraLibs ? [ ]
}:

stdenv.mkDerivation rec {
  pname = "st";
  version = "1.02";

  src = ./st;

  nativeBuildInputs = [ pkg-config fontconfig freetype ncurses ];
  buildInputs = [ libX11 libXft ] ++ extraLibs;

  buildPhase =
    lib.optionalString (lightMode == true) "cp lightmode.h colors.h; " +
    lib.optionalString (aristotle == true) "CFLAGS='-DARISTOTLE' " +
    ''
      make
    '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin
  '';

  meta = with lib; {
    description = "Customized builds of the st terminal emulator";
    homepage = "https://github.com/stupidcomputer/st";
    license = licenses.mit;
  };
}
