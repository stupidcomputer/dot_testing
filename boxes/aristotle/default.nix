{ pkgs, lib, machines, ... }:
{
  imports = [
    ./sshd.nix
    ./agenix.nix
    ./hardware-configuration.nix

    ../../config/aerc
    ../../config/sx
    ../../config/i3
    ../../config/i3pystatus
    ../../config/git
    ../../config/bash
    ../../config/nvim
    ../../config/emacs
    ../../config/khal
    ../../config/ssh
    ../../config/khard
    ../../config/isync
    ../../config/cmus
    ../../config/msmtp
    ../../config/neomutt
    ../../config/python
    ../../config/vdirsyncer
    ../../config/todoman
    ../../config/rbw
    ../../config/zathura
    ../../config/htop
    ../../config/games
    ../../config/termutils
    ../../config/productionutils
    ../../config/brave
    ../../config/tor-browser
    ../../config/scrcpy
    ../../config/hueadm
    ../../config/syncthing
    ../../config/ledger
  ];

  environment.systemPackages = with pkgs; [
    (callPackage ../../builds/st.nix { aristotle = true; })
    (callPackage ../../builds/dmenu.nix {})
    (callPackage ../../builds/utils.nix {})
    (callPackage ../../builds/rebuild.nix {})
    (callPackage ../../builds/sssg.nix {})
    (callPackage ../../builds/tilp.nix {})
  ];

  programs.kdeconnect.enable = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
  };

  networking = {
    hostName = "aristotle";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 24800 ];
    firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

    hosts = lib.attrsets.mergeAttrsList [
      (machines.mkHosts machines "router" "localnet")
      (machines.mkHosts machines "copernicus" "localnet")
      (machines.mkHosts machines "phone" "localnet")
      (machines.mkHosts machines "netbox" "internet")
    ] // {
      "127.0.0.2" = [ "cups.l" ];
    };
  };
  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.usr = {
    isNormalUser = true;
    description = "usr";
    extraGroups = [ "networkmanager" "wheel" "input" "adbusers" ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      windowManager.i3.enable = true;
      desktopManager.lxqt.enable = true;

      videoDrivers = [ "modesetting" ];
    };
    displayManager.sddm.enable = true;
    libinput.enable = true;
    tlp.enable = true;
  };

  powerManagement.powertop.enable = true;

  systemd.user.services.ssh-socks5-proxy = {
    enable = true;
    description = "SOCKS5 proxy over ssh";

    serviceConfig.ExecStart = "${pkgs.openssh}/bin/ssh -ND 127.0.0.1:4000 netbox";
    wantedBy = []; # start only when I say so
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    corefonts
    vistafonts
    proggyfonts
  ];

  system.stateVersion = "24.05";
}
