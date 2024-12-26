{ lib, config, pkgs, machines, ... }:

{
  services.openssh = {
    enable = true;
    ports = [55555];
    settings = {
      X11Forwarding = false;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  users.users.ryan.openssh.authorizedKeys.keys = [
    machines.copernicus.pubkey
    machines.aristotle.pubkey
    machines.phone.pubkey
  ];
}
