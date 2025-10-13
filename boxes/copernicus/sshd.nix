{ machines, ...}:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    listenAddresses = [
      {
        addr = "192.168.1.201";
        port = 2222;
      }
      {
        addr = "10.100.0.2";
        port = 2222;
      }
      {
        addr = "127.0.0.1";
        port = 2222;
      }
      {
        addr = "127.0.0.2";
        port = 2222;
      }
    ];
  };

  networking.firewall.interfaces.eno1 = {
    allowedTCPPorts = [ 2222 ];
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    machines.copernicus.pubkey
    machines.aristotle.pubkey
    machines.phone.pubkey
    machines.plato.pubkey
  ];
}
