{ stdenv
, lib
, pkgs
, fetchgit
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "jsfw";
  version = "1.00";

  src = fetchgit {
    url = "https://github.com/viandoxdev/jsfw";
    hash = "sha256-/aQGz0/aYM0fA+TUVXC9bYKV8AJVU+hTR6Srvmqn0Nk=";
  };

  buildPhase = ''
    make jsfw
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp jsfw $out/bin/jsfw
  '';
}
