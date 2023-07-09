{ stdenv
, lib
, fetchgit
, pkg-config
, libX11
, libXft
, fontconfig
, freetype
, ncurses
, extraLibs ? [ ]
}:

stdenv.mkDerivation rec {
  pname = "st";
  version = "69.19";

  src = fetchgit {
    url = "https://git.beepboop.systems/rndusr/st";
    sha256 = "sha256-zdID1SUnTO/zl90EG8TguBNYYCnrnqFnSLz32kQZbng=";
  };

  nativeBuildInputs = [ pkg-config fontconfig freetype ncurses];
  buildInputs = [ libX11 libXft ] ++ extraLibs;

  buildPhase = ''
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
