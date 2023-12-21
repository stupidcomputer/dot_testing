{ lib, config, pkgs, ...}:

{
  imports = [
    ../common/desktop.nix
    ../common/steam.nix
  ];

  environment.systemPackages = with pkgs; [
    gnome.cheese
    musescore
    libsForQt5.kdenlive
    xdotool
    texlive.combined.scheme-full
    lilypond
    virt-manager
#    virtualbox
    xsane
    android-studio
    mpc-cli
    emacs
    nyxt
    cmus
  ];

#  users.extraGroups.vboxusers.members = [ "usr" ];
#  virtualisation.virtualbox.host.enable = true;
#  virtualisation.virtualbox.host.enableExtensionPack = true;

  services.tlp.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  networking.hostName = "xps";

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  users.users.usr.extraGroups = [ "libvirtd" ];
}
