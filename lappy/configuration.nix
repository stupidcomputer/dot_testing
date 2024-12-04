{ config, pkgs, lib, ... }:

{
  imports = [
    ./builds
    ./config
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
  };
  hardware = {
    pulseaudio.enable = true;
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
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # x11
    brave
    (pkgs.st.overrideAttrs (oldAttrs: rec {
        patches = [
          ./builds/st/scrollback.patch
          ./builds/st/clipboard.patch
        ];
        conf = builtins.readFile ./builds/st/config.h;
    }))
    dmenu
    pinentry-qt

    # tui/cli programs
    # devel
    gh
    tea
    neovim
    git

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
    usbutils # for lsusb
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

  # make sshd a `systemctl start sshd` command away
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [];

  system.stateVersion = "24.05";
}
