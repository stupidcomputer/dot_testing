{ lib, config, pkgs, ...}:

{
  imports = [
    ./gnupg.nix
    ./fonts.nix
    ./pulse.nix
    ./sxiv.nix
  ];

  environment.systemPackages = with pkgs; [
    bspwm
    sxhkd
    xscreensaver

    # non-x11 things, but common to the desktops
    bluetuith
    brave
    vdirsyncer
    isync
    khal
    todoman
    sshfs
    rsync
    msmtp
    ytfzf
  ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    layout = "us";

    displayManager.sx.enable = true;
  };
}
