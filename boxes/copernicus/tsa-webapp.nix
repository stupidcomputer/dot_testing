{ pkgs, ... }:
let
  exposedPort = 1923;
in {
  systemd.services.tsa-webapp = {
    description = "TSA Webmaster 2026 Django App";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.nix}/bin/nix-shell -I nixpkgs=${pkgs.path} /home/usr/git/tsa-webmaster-2026/shell.nix --run 'python /home/usr/git/tsa-webmaster-2026/tsawebsite/manage.py runserver 0.0.0.0:${toString exposedPort}'";
      WorkingDirectory = "/home/usr/git/tsa-webmaster-2026/tsawebsite";
      Restart = "on-failure";
      User = "usr";
    };
  };

  networking.firewall.allowedTCPPorts = [ exposedPort ];
}