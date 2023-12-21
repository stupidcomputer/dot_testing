{ lib, config, pkgs, ... }:

let
my_neovim = pkgs.neovim.overrideAttrs (oldAttrs: {
  buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.luajitPackages.luaexpat ];
});
in {
  imports =
    [
      ../hardware-configuration.nix # include the results of the hardware scan
    ];

  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    curl
    htop
    git
    tree
    dig
    htop
    gnumake

    (pkgs.callPackage ../builds/rebuild.nix {})
  ];

  system.stateVersion = "23.11"; # don't change this, lol
}
