{ machines, ...}:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      X11Forwarding = "yes";
      X11DisplayOffset = "10";
    };
    listenAddresses = [
      {
        addr = "192.168.1.201";
        port = 2222;
      }
    ];
  };

  networking.firewall.interfaces.eno1 = {
    allowedTCPPorts = [ 2222 ];
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    machines.aristotle.pubkey
    machines.copernicus.pubkey
    machines.phone.pubkey
    machines.hammurabi.pubkey
  ];
}
