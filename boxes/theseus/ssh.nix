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

      # Required for ProxyJump (-J) and stdio forwarding (-W), as well as
      # ssh -L / -R style forwards.
      AllowTcpForwarding = true;
      AllowStreamLocalForwarding = true;

      # Be explicit: allow forwarding destinations and remote-listen ports.
      # (Useful if we later add restrictive defaults.)
      PermitOpen = "any";
      PermitListen = "any";

      # Allow remote forwards (-R) to bind beyond localhost *when requested*.
      # (Does not expose anything unless a client sets up -R.)
      GatewayPorts = "clientspecified";

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
