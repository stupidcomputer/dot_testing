{ lib, config, pkgs, inputs, ...}:

{
  imports = [
    ./bash.nix
  ];

  environment.systemPackages = [
# is it this? this throws a similar error; no attr st, etc.
    inputs.utilpkg.packages.x86_64-linux.st
    inputs.utilpkg.packages.x86_64-linux.rebuild
    inputs.utilpkg.packages.x86_64-linux.utils
    pkgs.man-pages
  ];


  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.usr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "usr";
  };
}
