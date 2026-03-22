{ pkgs, ... }:
{
  users.users.syncthing = {
    isNormalUser = true;
    home = "/home/syncthing";
  };

  systemd.services.start-syncthing = {
    description = "start the syncthing service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "syncthing";
      ExecStart = "${pkgs.syncthing}/bin/syncthing";
      Restart = "on-failure";

      ProtectHome = false;
      WorkingDirectory = "/home/syncthing";
    };
  };
}
