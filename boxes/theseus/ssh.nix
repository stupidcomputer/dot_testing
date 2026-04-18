{ pkgs, machines, ... }:
{
  services.openssh = {
    enable = true;
    listenAddresses = [
      {
        addr = "127.0.0.1";
        port = 55555;
      }
      {
        addr = "10.100.0.1";
        port = 22;
      }
    ];
    settings = {
      X11Forwarding = false;
      AllowTcpForwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  systemd.services.sshd = {
    requires = [ "wg-quick-wg0.service" ];
    after = [ "wg-quick-wg0.service" ];
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    machines.copernicus.pubkey
    machines.hammurabi.pubkey
    machines.phone.pubkey
  ];
}
