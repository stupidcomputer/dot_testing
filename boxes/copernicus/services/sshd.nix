{ machines, ...}:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  users.users.usr.openssh.authorizedKeys.keys = [
    machines.copernicus.pubkey
    machines.aristotle.pubkey
    machines.phone.pubkey
  ];
}
