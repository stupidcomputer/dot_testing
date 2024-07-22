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
    ];

  # nix optimization
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
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

  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/vda";
  };

  users.users.ryan = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbhM3wj0oqjR3pUaZgpfX4Xo4dlzvBTbQ48zHyg7Pwx usr" # x230t
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBGh1FHPneg7PCDkhMs2BCJPTIRVJkRTKpOj1w02ydD usr" # copernicus
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrpVDLQszFKoYbvYKRyVTTpehxR0BVU47SXkz39l2wK usr" # mainsail
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZw5bg0TrvSkW/XQa4c+2iLbIKOxfMGbjy5Nb3HSfBv usr" # phone
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
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
