{ pkgs, machines, ... }:
{
  services.openssh = {
    enable = true;
    ports = [55555];
    settings = {
      X11Forwarding = false;
      AllowTcpForwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    machines.aristotle.pubkey
    machines.copernicus.pubkey
    machines.hammurabi.pubkey
    machines.phone.pubkey
    machines.plato.pubkey
  ];
}
