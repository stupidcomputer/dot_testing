{ python3Packages, fetchgit }:
with python3Packages;
let
  repo = fetchgit {
    url = "https://github.com/stupidcomputer/flasktrack";
    hash = "sha256-KzX5BhFcrv+LUxYnkiQg5ooJLKa08etJ5x2aUqy2d5E=";
  };
in buildPythonApplication rec {
  pname = "flasktrack";
  version = "0.01";

  propagatedBuildInputs = [ flask ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/${python.sitePackages}
    cp -r . $out/${python.sitePackages}/flasktrack

    runHook postInstall
  '';
  shellHook = "export FLASK_APP=flasktrack";
  format = "other";

  src = "${repo}/flasktrack";
}
