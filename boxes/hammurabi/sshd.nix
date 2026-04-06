{ machines, ...}:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
      X11DisplayOffset = "10";
    };
    listenAddresses = [
      {
        addr = machines.hammurabi.ip-addrs.intnet;
        port = 22;
      }
    ];
  };

  networking.firewall.interfaces.wg0 = {
    allowedTCPPorts = [ 22 ];
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    machines.copernicus.pubkey
    machines.hammurabi.pubkey
    machines.phone.pubkey
    machines.theseus.pubkey
  ];
}
