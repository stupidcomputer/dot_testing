{ pkgs, lib, machines, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/bootstrap.nix

    ./bind.nix
    ./calendar-sync.nix
    ./flagman.nix
    ./flasktrack.nix
    ./guacamole.nix
    ./nginx.nix
    ./ssh.nix
    ./sslh.nix
    ./syncthing.nix
    ./tsa-webmaster-26.nix
    ./vaultwarden.nix
    ./wireguard.nix
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

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    python3
    curl
    htop
    git
    tree
    dig
    htop
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
        wg0 = {
          # allow everything bound to the wg0 interface
          allowedTCPPortRanges = [
            { from = 1; to = 35565; }
          ];
          allowedUDPPortRanges = [
            { from = 1; to = 35565; }
          ];
        };
      };
    };
    hosts = lib.attrsets.mergeAttrsList [
      (machines.mkHosts machines "copernicus" "intnet")
    ];
  };
}
