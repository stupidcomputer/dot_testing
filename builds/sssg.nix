{ python3Packages, fetchgit }:
with python3Packages;
buildPythonApplication {
  pname = "sssg";
  version = "1.1";

  propagatedBuildInputs = [ markdown jinja2 watchdog ];

  src = fetchgit {
    url = "https://git.beepboop.systems/stupidcomputer/sssg";
    hash = "sha256-PJCa1hO24ctM0RFiBCNt2rZkIaDO77zYgxOp3EE337c=";
  };
}
