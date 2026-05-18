{ lib
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "input-forward";
  version = "0.1.0";
  pyproject = true;

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    python3Packages.hatchling
  ];

  propagatedBuildInputs = [
    python3Packages.evdev
  ];

  pythonImportsCheck = [ "input_forward" ];

  doCheck = false;

  meta = with lib; {
    description = "Forward local evdev keyboard and mouse devices over SSH to remote uinput";
    mainProgram = "input-forward";
    platforms = platforms.linux;
  };
}
