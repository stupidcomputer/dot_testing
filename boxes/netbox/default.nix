{ pkgs, lib, machines, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../lib/bootstrap.nix

    ./flasktrack.nix
    ./franklincce.nix
    ./mail.nix
    ./nginx.nix
    ./ssh.nix
    ./sslh.nix
    ./vaultwarden.nix
  ];

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
    htop
    neovim
    tmux

    syncthing
  ];

  system = {
    stateVersion = "23.05"; # don't change this, lol
  };

  services.journald.extraConfig = ''
    SystemMaxUse=1G
  '';

  system.userActivationScripts = {
    copyEssentialConfiguration = {
      # we don't want to bring in the entirety of home-manager for this, so just
      # write some files as a hack
      text = ''
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/config/bash/bashrc /home/ryan/.bashrc
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/config/bash/profile /home/ryan/.bash_profile
        ${pkgs.coreutils}/bin/mkdir -p /home/ryan/config/nvim
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/config/nvim/init.min.lua /home/ryan/.config/nvim/init.lua
      '';
      deps = [];
    };
  };

  system.activationScripts = {
    copyEssentialConfiguration = {
      text = ''
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/config/bash/bashrc /root/.bashrc
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/config/bash/profile /root/.bash_profile
        ${pkgs.coreutils}/bin/mkdir -p /root/config/nvim
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/config/nvim/init.lua /root/.config/nvim/init.lua
      '';
      deps = [];
    };
  };

  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/vda";
  };

  users.users.ryan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  networking = {
    usePredictableInterfaceNames = false;
    hostName = "netbox";

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
      (machines.mkHosts machines "copernicus" "wgnet")
      (machines.mkHosts machines "aristotle" "wgnet")
    ];
  };
}
