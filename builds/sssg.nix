{ python3Packages, fetchgit }:
with python3Packages;
buildPythonApplication {
  pname = "sssg";
  version = "1.1";

  propagatedBuildInputs = [ markdown jinja2 watchdog ];

  src = fetchgit {
    url = "https://git.beepboop.systems/stupidcomputer/sssg";
    hash = "sha256-17FRRgOGH/ZF6IrTprubiaZI/ihFSB4zu1spoxUZ2bA=";
  };
}
