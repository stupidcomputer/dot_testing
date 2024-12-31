{ stdenv
, libX11
, libXinerama
, libXft
}:

stdenv.mkDerivation rec {
  pname = "dwm";
  version = "6.5";

  src = ./dwm;

  buildInputs = [ libX11 libXinerama libXft ];

  installPhase = ''
    mkdir -p $out/bin
    cp dwm $out/bin
    cp dwm-setstatus $out/bin
  '';
}
