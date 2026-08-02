{ pkgs, ppkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix
    ../../common/bootstrap.nix
    ./agenix.nix
    ./sshd.nix
  ];

  virtualisation.virtualbox.guest.enable = true;
  services.ryande.enable = true;

  networking = {
    hostName = "descartes";
    networkmanager.enable = true;
    firewall.checkReversePath = false;
  };

  security.sudo.extraRules = [
    {
      users = [ "usr" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  # don't touch these
  system.stateVersion = "25.05";
  home-manager.users.usr.home.stateVersion = "25.05";
}
