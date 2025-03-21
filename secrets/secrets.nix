let
  machines = import ../lib/machines.nix;
  server-netbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvinRGdd9GuiPnZYBQPzraXeBxeStwakzmtfzNNpDxy";

  all = [ server-netbox machines.copernicus.pubkey machines.aristotle.pubkey ];
in {
  # mailserver
  "mailaccount.age".publicKeys = all;

  # wireguard
  "netbox-wg-priv.age".publicKeys = all;
  "copernicus-wg-priv.age".publicKeys = with machines; [ copernicus.pubkey aristotle.pubkey ];

  # radicale
  "radicale-passwd.age".publicKeys = all;

  # networkmanager
  "nm-home-net-config.age".publicKeys = with machines; [ copernicus.pubkey aristotle.pubkey ];

  # pcomon
  "pcomon-secrets-file.age".publicKeys = [ machines.copernicus.pubkey machines.aristotle.pubkey server-netbox ];

  # router configuration
  "r8000-config.cfg.age".publicKeys = [ machines.copernicus.pubkey machines.aristotle.pubkey ];
}
