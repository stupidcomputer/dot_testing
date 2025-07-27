{ lib, machines, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 2222;
      }
    ];
  };

  systemd.user.services.ssh-socks5-proxy = {
    enable = true;
    description = "SOCKS5 proxy over ssh";

    serviceConfig.ExecStart = "${pkgs.openssh}/bin/ssh -ND 127.0.0.1:4000 netbox";
    wantedBy = [];
  };

  users.users.usr.openssh.authorizedKeys.keys = with machines; [
    copernicus.pubkey
    aristotle.pubkey
    phone.pubkey
  ];

  networking.firewall.allowedTCPPorts = [ 2222 ];

  # don't start the sshd immediately
  systemd.services.sshd.wantedBy = lib.mkForce [];
}
