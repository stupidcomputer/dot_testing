let
  machines = import ../lib/machines.nix;
  server-netbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvinRGdd9GuiPnZYBQPzraXeBxeStwakzmtfzNNpDxy";

  all = [ server-netbox machines.copernicus.pubkey machines.aristotle.pubkey ];
in {
  # gitea
  "gitea-postgres-password.age".publicKeys = all;

  # mailserver
  "mailaccount.age".publicKeys = all;

  # wireguard
  "netbox-wg-priv.age".publicKeys = all;
  "copernicus-wg-priv.age".publicKeys = all;

  # radicale
  "radicale-passwd.age".publicKeys = all;

  # nextcloud
  "nextcloud-admin-passwd.age".publicKeys = all;
}
