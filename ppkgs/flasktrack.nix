{ python3Packages, fetchgit }:
with python3Packages;
let
  repo = fetchgit {
    url = "https://github.com/stupidcomputer/flasktrack";
    hash = "sha256-3rFrdW2N1hLm1KwchX15eFPOB+QV1sFiux99ENfH0Rw=";
  };
in buildPythonApplication rec {
  pname = "flasktrack";
  version = "0.02";

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
