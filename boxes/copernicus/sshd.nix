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
        addr = machines.copernicus.ip-addrs.localnet;
        port = 2222;
      }
      {
        addr = machines.copernicus.ip-addrs.intnet;
        port = 22;
      }
    ];
  };

  networking.firewall.interfaces.eno1 = {
    allowedTCPPorts = [ 2222 ];
  };

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 22 ];
  };

  users.users.usr.openssh.authorizedKeys.keys = machines.copernicus.allowed-ssh-access;
}
