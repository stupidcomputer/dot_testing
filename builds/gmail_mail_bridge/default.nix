{ pkgs, pythonPackages ? (import <nixpkgs> {}).python3Packages }:
pythonPackages.buildPythonPackage {
  name = "gmail_mail_bridge";
  src = ./gmail_mail_bridge;

  propagatedBuildInputs = [ pythonPackages.flask pkgs.system-sendmail ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${pythonPackages.python.sitePackages}
    cp -r . $out/${pythonPackages.python.sitePackages}/gmail_mail_bridge

    runHook postInstall
  '';

  shellHook = "export FLASK_APP=gmail_mail_bridge";

  format = "other";
}
