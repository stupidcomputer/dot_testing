{ lib, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/bootstrap.nix

      ./radicale.nix
      ./ssh.nix
      ./gitea.nix
      ./radicale.nix
      ./vaultwarden.nix
      ./sslh.nix
      ./rss2email.nix
      ./fail2ban.nix
      ./nginx.nix
      ./franklincce.nix
      ./wireguard.nix
      ./prometheus.nix
      ./socks.nix

      ./nextcloud-bridge.nix
      ./grafana-bridge.nix
      ./guacamole-bridge.nix
      ./paperless-bridge.nix
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
  ];

  system = {
    copySystemConfiguration = true;
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
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/.config/bash/bashrc /home/ryan/.bashrc
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/.config/bash/profile /home/ryan/.bash_profile
        ${pkgs.coreutils}/bin/mkdir -p /home/ryan/.config/nvim
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/.config/nvim/init.min.lua /home/ryan/.config/nvim/init.lua
      '';
      deps = [];
    };
  };

  system.activationScripts = {
    copyEssentialConfiguration = {
      text = ''
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/.config/bash/bashrc /root/.bashrc
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/.config/bash/profile /root/.bash_profile
        ${pkgs.coreutils}/bin/mkdir -p /root/.config/nvim
        ${pkgs.coreutils}/bin/cp /home/ryan/dot_testing/.config/nvim/init.min.lua /root/.config/nvim/init.lua
      '';
      deps = [];
    };
  };

  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/vda";
  };

  users.users.ryan = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbhM3wj0oqjR3pUaZgpfX4Xo4dlzvBTbQ48zHyg7Pwx usr" # x230t
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBGh1FHPneg7PCDkhMs2BCJPTIRVJkRTKpOj1w02ydD usr" # copernicus
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrpVDLQszFKoYbvYKRyVTTpehxR0BVU47SXkz39l2wK usr" # mainsail
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2xUbQw9+RCPVw7qCFm4NNCP/MpS2BIArcwMv0KdKOI usr" # mlg
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuVT5W3kzjzsuMIWk1oeGtL8jZGtAhRSx8dK8oBJQcG u0_a291" # phone
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCufie2JWc4ylZHIi03uR0RB/79/hTacn9qnlzqs+kaWcdk7eyHqpg3zmVrETCZQxJ8ssZx4+tlwC0+seOjgIfNktfKjiRpes2Sib0MowO3lRgzqJ0pZ5AEA/pc4314meAZP/CibFw54CWxOySEXsCWKm157HVJHpJ7P0HwqzHod4jXxUWKwMoZo5XyOTTMHv4oytcHTydIeiSymw3RtvEtqpBCRE3W5kIiJNuCXnZGZBxvOnhJsQ0FkeXgByeXOLFxUw0ma6Jy/621T2GrBnmFhiSIV+T7xk/cfgP+D1V9x2wCLX5gPQaNzwL03v3xohxnJwRa6EXTR9LzXE7Rhnolbmkb/YPPpI6U0RpueZrHv/1CIA3OSKnQh1cp/jMeP4DfeO+fSY1SsRZICQ3ndlnYkXtalEzGPxeLUgLsh6SxSIK+7jjlDGrJCUbOMHhR+92vBXy7XE8tgO2FuhrAIiroIsaWmZO/7sike3ps3GFEZHZMEe2v3IDqfX/Iecn++U= usr" # aristotle
    ];
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  networking = {
    usePredictableInterfaceNames = false;
    networkmanager.enable = true;
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
  };
}
