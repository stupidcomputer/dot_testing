{ machines, ... }:

{
  services.openssh = {
    enable = true;
    openFirewall = false; # only reachable over tailscale, see below
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = true;
      X11DisplayOffset = "10";
    };
  };

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 22 ];
  };

  users.users.usr.openssh.authorizedKeys.keys = machines.kant.allowed-ssh-access;
}
