{ pkgs, lib, machines, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/bootstrap.nix
    ../../common/tailscale.nix

    ./calendar-sync.nix
    ./flagman.nix
    ./flasktrack.nix
    ./headscale.nix
    ./nginx.nix
    ./ssh.nix
    ./sslh.nix
    ./syncthing.nix
    ./vaultwarden.nix
  ];

  age.identityPaths = [ "/home/usr/.ssh/id_ed25519" ];

  nix = {
    optimise = {
      automatic = true;
      dates = [ "02:30" ];
    };
    gc = {
      automatic = true;
      dates = "03:15";
      options = "-d";
    };
    settings.trusted-users = [ "@wheel" ];
  };
  services.nginx.virtualHosts = lib.genAttrs [
    "beepboop.systems" "tools.beepboop.systems" "intnet.beepboop.systems"
    "bit.beepboop.systems" "bitwarden.beepboop.systems" "calendars.beepboop.systems"
    "flagmanager.net" "flasktrack.beepboop.systems" "hs.beepboop.systems"
  ] (_: { http2 = false; });

  # exit node
  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-exit-node" ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=200M
  '';

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    python3
    curl
    htop
    git
    tree
    dig
    neovim
    tmux

    syncthing
  ];

  system = {
    stateVersion = "25.11"; # don't change this, lol
  };

  system.userActivationScripts = {
    copyEssentialConfiguration = {
      # we don't want to bring in the entirety of home-manager for this, so just
      # write some files as a hack
      text = ''
        ${pkgs.coreutils}/bin/cp /home/usr/dot_testing/config/bash/bashrc /home/usr/.bashrc
        ${pkgs.coreutils}/bin/cp /home/usr/dot_testing/config/bash/profile /home/usr/.bash_profile
        ${pkgs.coreutils}/bin/mkdir -p /home/usr/.config/nvim
        ${pkgs.coreutils}/bin/cp /home/usr/dot_testing/config/nvim/init.min.lua /home/usr/.config/nvim/init.lua
        ${pkgs.coreutils}/bin/cp /home/usr/dot_testing/config/bash/bashrc /root/.bashrc
        ${pkgs.coreutils}/bin/cp /home/usr/dot_testing/config/bash/profile /root/.bash_profile
        ${pkgs.coreutils}/bin/mkdir -p /root/.config/nvim
        ${pkgs.coreutils}/bin/cp /home/usr/dot_testing/config/nvim/init.lua /root/.config/nvim/init.lua
      '';
      deps = [];
    };
  };

  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/vda";
  };

  users.users.usr = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  networking = {
    usePredictableInterfaceNames = false;
    hostName = "theseus";

    firewall = {
      enable = true;
      interfaces = {
        eth0 = {
          allowedTCPPorts = [ 80 443 ];
        };
      };
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    # theseus doesn't use MagicDNS, but needs these for ssh -J
    hosts = {
      ${machines.copernicus.ip-addrs.intnet} = [ "copernicus" "copernicus.ts.beepboop.systems" ];
      ${machines.hammurabi.ip-addrs.intnet} = [ "hammurabi" "hammurabi.ts.beepboop.systems" ];
    };
  };
}
