let
  machines = import ../lib/machines.nix;
  server-netbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvinRGdd9GuiPnZYBQPzraXeBxeStwakzmtfzNNpDxy";

  all = [ server-netbox machines.copernicus.pubkey machines.aristotle.pubkey ];
in {
  "gitea-postgres-password.age".publicKeys = all;
}
