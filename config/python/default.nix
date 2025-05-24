{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3
  ];

  system.userActivationScripts.copyPythonConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/python
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/python/pythonrc.py /home/usr/.config/python/pythonrc.py
    '';
    deps = [];
  };
}
