{ pkgs, lib, machines, ... }:

{
  imports = [
    ../../lappy-config
    ./paperless.nix
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
  };

  networking = {
    hostName = "aristotle";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 24800 ];

    hosts = lib.attrsets.mergeAttrsList [
      (machines.mkHosts machines "router" "localnet")
      (machines.mkHosts machines "copernicus" "localnet")
      (machines.mkHosts machines "phone" "localnet")
      (machines.mkHosts machines "netbox" "internet")
    ] // {
      "127.0.0.1" = [ "news.ycombinator.com" ];
    };
  };
  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "bredr";
    };
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.usr = {
    isNormalUser = true;
    description = "usr";
    extraGroups = [ "networkmanager" "wheel" "input" ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  fonts.packages = with pkgs; [
    fantasque-sans-mono
  ];

  environment.systemPackages = with pkgs; [
    # x11
    brave
    qutebrowser
    (callPackage ../../builds/st.nix { aristotle = true; })
    (callPackage ../../builds/lappy-utils.nix {})
    (callPackage ../../builds/dwm.nix {})
    (callPackage ../../builds/sssg.nix {})
    dmenu
    pinentry-qt

    # tui/cli programs
    # devel
    gh
    tea
    neovim
    git
    git-annex

    # audio
    cmus
    ncpamixer
    bluetuith

    # pimtools
    khard
    khal
    vdirsyncer
    neomutt
    isync
    msmtp
    todoman

    # utilities
    htop
    tmux
    rbw
    elinks
    lynx
    jq
    peaclock
    usbutils # for lsusb
    pciutils # for lspci
    kjv
    epr
    poppler_utils
    ledger
    gnuplot
    anki-bin

    # for the remote access functionality
    vscode-fhs
  ];

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    libinput.enable = true;
    tlp.enable = true;
  };

  powerManagement.powertop.enable = true;

  systemd.services."getty@tty6" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = ["" "@${pkgs.coreutils}/bin/cat"];
  };

  systemd.user.services.ssh-socks5-proxy = {
    enable = true;
    description = "SOCKS5 proxy over ssh";

    serviceConfig.ExecStart = "${pkgs.openssh}/bin/ssh -ND 127.0.0.1:4000 netbox";
    wantedBy = []; # start only when I say so
  };

  # make sshd a `systemctl start sshd` command away
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [];

  system.stateVersion = "24.05";
}
