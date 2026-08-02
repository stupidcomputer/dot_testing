{ lib, machines, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
      X11DisplayOffset = "10";
    };
  };

  networking.firewall.interfaces.wg0 = {
    allowedTCPPorts = [ 22 ];
  };

  systemd.services.sshd.wantedBy = lib.mkForce [ ];

  users.users.usr.openssh.authorizedKeys.keys = machines.descartes.allowed-ssh-access;
}
