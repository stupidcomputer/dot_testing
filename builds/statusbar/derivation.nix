{ lib, python3Packages }:
with python3Packages;
buildPythonApplication {
  pname = "statusbar";
  version = "1.0";

  propagatedBuildInputs = [ ];

  src = ./.;
}
