{ stdenv
, libX11
, libXinerama
, libXft
}:

stdenv.mkDerivation rec {
  pname = "dwm";
  version = "6.5";

  src = builtins.fetchGit {
    url = "https://github.com/stupidcomputer/dwm.git";
    rev = "7248b43424def635e2a6194281e84ec0689fd7ba";

  };

  buildInputs = [ libX11 libXinerama libXft ];

  installPhase = ''
    mkdir -p $out/bin
    cp dwm $out/bin
    cp dwm-setstatus $out/bin
  '';
}
