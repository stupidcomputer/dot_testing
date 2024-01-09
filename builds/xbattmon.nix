{ stdenv
, lib
, fetchgit
, pkg-config
, libX11
, libXft
, libXinerama
, fontconfig
, freetype
, ncurses
, extraLibs ? [ ]
}:

stdenv.mkDerivation rec {
  pname = "xbattmon";
  version = "69.19";

  src = fetchgit {
    url = "https://git.beepboop.systems/rndusr/xbattmon";
    sha256 = "sha256-mM5pjyBw+1lJoaXt0BNiXmqGRt0U2ABENitA8K/EZ9E=";
  };

  nativeBuildInputs = [ pkg-config fontconfig freetype ncurses ];
  buildInputs = [ libX11 libXft libXinerama ] ++ extraLibs;

  buildPhase = ''
    ./configure
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
