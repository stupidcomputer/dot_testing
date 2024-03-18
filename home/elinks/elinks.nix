{ lib, stdenv, fetchFromGitHub, ncurses, libX11, bzip2, zlib
, brotli, zstd, xz, openssl, autoreconfHook, gettext, pkg-config, libev
, gpm, libidn, tre, expat, luajit
}:

stdenv.mkDerivation rec {
  pname = "elinks";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "rkd77";
    repo = "elinks";
    rev = "v${version}";
    hash = "sha256-JeUiMHAqSZxxBe8DplzmzHzsY6KqoBqba0y8GDwaR0Y=";
  };

  buildInputs = [
    ncurses libX11 bzip2 zlib brotli zstd xz
    openssl libidn tre expat libev luajit
  ]
    ++ lib.optional stdenv.isLinux gpm
    ;

  nativeBuildInputs = [ autoreconfHook gettext pkg-config ];

  configureFlags = [
    "--enable-finger"
    "--enable-html-highlight"
    "--enable-gopher"
    "--enable-gemini"
    "--enable-cgi"
    "--enable-bittorrent"
    "--enable-nntp"
    "--enable-256-colors"
    "--enable-true-color"
    "--with-brotli"
    "--with-lzma"
    "--with-libev"
    "--with-terminfo"
  ];

  meta = with lib; {
    description = "Full-featured text-mode web browser";
    homepage = "https://github.com/rkd77/elinks";
    license = licenses.gpl2;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ iblech gebner ];
  };
}
