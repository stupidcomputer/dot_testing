{ lib, config, pkgs, ...}:

let
  customPolybar = pkgs.polybar.override {
    alsaSupport = true;
    pulseSupport = true;
  };
in {
  imports = [
    ./main.nix
  ];

  services.xserver = {
    enable = true;
    libinput.enable = true;
    layout = "us";

    displayManager.sx.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "libxls-1.6.2"
    ];
  };

  environment.systemPackages = with pkgs; [
    sx
    fzy
    xclip
    xcape
    ffmpeg
    man-pages

    ncmpcpp
    pciutils
    tor-browser-bundle-bin
    xscreensaver
    ncpamixer
    gpick
    calcurse
    dunst
    libnotify
    tig
    mpv
    yt-dlp
    tmux
    lynx
    feh
    elinks
    sc-im
    ledger
    remind
    python3
    pinentry-curses
    magic-wormhole
    xbrightness
    xdotool
    figlet
    neomutt

    unzip
    lua-language-server
    rnix-lsp
    python311Packages.jedi-language-server

    ungoogled-chromium
    discord

    customPolybar
    (pkgs.callPackage ../builds/utils.nix {})
    (pkgs.callPackage ../builds/st.nix {})
    (pkgs.callPackage ../builds/pash.nix {})
  ];

  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  users.users.usr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "usr";
    packages = with pkgs; [
      tree
      bspwm
      sxhkd
    ];
  };

  # honking impure, but who's counting anyway?
  system.activationScripts.test-script.text = ''
    #!${pkgs.bash}/bin/bash

    if [ "$(${pkgs.coreutils}/bin/whoami)" = "usr"]; then
      ${pkgs.coreutils}/bin/mkdir -p /home/usr/git
      ${pkgs.git}/bin/git https://git.beepboop.systems/rndusr/dot /home/usr/git/dot
      ${pkgs.git}/bin/git https://git.beepboop.systems/rndusr/privdata /home/usr/git/privdata
    fi
  '';

  environment.etc = {
    "profile.local" = {
      text = "source /home/usr/.config/bash/profile";
    };
    "bashrc.local" = {
      text = "source /home/usr/.config/bash/bashrc";
    };
  };
}
