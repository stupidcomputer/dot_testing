{ python3Packages, fetchgit }:
with python3Packages;
buildPythonApplication rec {
  pname = "flasktrack";
  version = "1.0.0";
  format = "other";

  propagatedBuildInputs = [ flask ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/${pythonPackages.python.sitePackages}
    cp -r ./${pname} $out/${pythonPackages.python.sitePackages}/${pname}

    runHook postInstall
  '';
  shellHook = "export FLASK_APP=${pname}";

  src = fetchgit {
    url = "https://git.beepboop.systems/stupidcomputer/flasktrack";
    hash = "sha256-ezR+Y0ciA5+SVEOIWYUtmVxMeNpcVKXOBe1OSgYm0sA=";
  };
}
