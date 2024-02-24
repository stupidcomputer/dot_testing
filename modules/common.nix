{ lib, config, pkgs, inputs, ...}:

{
  imports = [
    ./bash.nix
  ];

  environment.systemPackages = [
    (pkgs.callPackage ../builds/rebuild.nix {})
    (pkgs.callPackage ../builds/st.nix {})
    (pkgs.callPackage ../builds/utils.nix {})
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
