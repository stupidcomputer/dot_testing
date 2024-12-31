{ lib, machines, ... }:
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

  users.users.usr.openssh.authorizedKeys.keys = with machines; [
    copernicus.pubkey
    aristotle.pubkey
    phone.pubkey
  ];

  networking.firewall.allowedTCPPorts = [ 2222 ];

  # don't start the sshd immediately
  systemd.services.sshd.wantedBy = lib.mkForce [];
}
