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
, colorscheme ? null
}:

stdenv.mkDerivation rec {
  pname = "st";
  version = "1.03";

  src = fetchgit {
    url = "https://git.beepboop.systems/rndusr/st";
    sha256 = "sha256-zdID1SUnTO/zl90EG8TguBNYYCnrnqFnSLz32kQZbng=";
  };

  nativeBuildInputs = [ pkg-config fontconfig freetype ncurses ];
  buildInputs = [ libX11 libXft ] ++ extraLibs;

  buildPhase = if colorscheme == null then ''
    make
  '' else ''
    mv normal_colors.h colors.h
    sed -i colors.h "s/base00/${colorscheme.palette.base00}/g"
    sed -i colors.h "s/base01/${colorscheme.palette.base01}/g"
    sed -i colors.h "s/base02/${colorscheme.palette.base02}/g"
    sed -i colors.h "s/base03/${colorscheme.palette.base03}/g"
    sed -i colors.h "s/base04/${colorscheme.palette.base04}/g"
    sed -i colors.h "s/base05/${colorscheme.palette.base05}/g"
    sed -i colors.h "s/base06/${colorscheme.palette.base06}/g"
    sed -i colors.h "s/base07/${colorscheme.palette.base07}/g"
    sed -i colors.h "s/base08/${colorscheme.palette.base08}/g"
    sed -i colors.h "s/base09/${colorscheme.palette.base09}/g"
    sed -i colors.h "s/base0A/${colorscheme.palette.base0A}/g"
    sed -i colors.h "s/base0B/${colorscheme.palette.base0B}/g"
    sed -i colors.h "s/base0C/${colorscheme.palette.base0C}/g"
    sed -i colors.h "s/base0D/${colorscheme.palette.base0D}/g"
    sed -i colors.h "s/base0E/${colorscheme.palette.base0E}/g"
    sed -i colors.h "s/base0F/${colorscheme.palette.base0F}/g"
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
