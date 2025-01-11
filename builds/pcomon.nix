{ python3Packages, system-sendmail, fetchgit }:
with python3Packages;
buildPythonApplication {
  pname = "pcomon";
  version = "1.0.0";

  propagatedBuildInputs = [ requests system-sendmail ];

  src = fetchgit {
    url = "https://git.beepboop.systems/stupidcomputer/pcomon";
    hash = "sha256-XxPb1WWq5YQz+UZ7P5dgInPweSD+52R2XVmoVrV0GMQ=";
  };
}
