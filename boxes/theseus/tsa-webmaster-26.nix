{ pkgs, ... }:
let
  username = "tsa-webmaster-26";
  homePath = "/home/${username}";
  internalPort = 1923;
in {
  services.nginx.virtualHosts."${username}.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://0.0.0.0:${toString internalPort}";
      extraConfig = ''
        port_in_redirect off;
        absolute_redirect off;
      '';
    };
  };

  users.users."${username}" = {
    isNormalUser = true;
    home = "${homePath}";
  };

  systemd.services.tsa-webapp = {
    description = "TSA Webmaster 2026 Django App";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.nix}/bin/nix-shell -I nixpkgs=${pkgs.path} ${homePath}/tsa-webmaster-2026/shell.nix --run 'python ${homePath}/tsa-webmaster-2026/tsawebsite/manage.py runserver 0.0.0.0:${toString internalPort}'";
      WorkingDirectory = "${homePath}/tsa-webmaster-2026/tsawebsite";
      Restart = "on-failure";
      User = username;
    };
  };
}
