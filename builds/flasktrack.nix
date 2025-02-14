{ python3Packages, fetchgit }:
with python3Packages;
buildPythonApplication rec {
  pname = "flasktrack";
  version = "1.0.0";
  shellHook = "export FLASK_APP=${pname}";

  src = fetchgit {
    url = "https://git.beepboop.systems/stupidcomputer/flasktrack";
    hash = "sha256-5XZn0OLcCh08cusR1/Ct0OJfej6ZYn4TiNK9FaS08fM=";
  };
}
