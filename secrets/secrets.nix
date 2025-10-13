let
  machines = import ../lib/machines.nix;
  server-netbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvinRGdd9GuiPnZYBQPzraXeBxeStwakzmtfzNNpDxy";

  all = [ server-netbox machines.copernicus.pubkey machines.aristotle.pubkey machines.plato.pubkey ];
in {
  # mailserver
  "mailaccount.age".publicKeys = all;

  # wireguard
  "netbox-wg-priv.age".publicKeys = all;
  "copernicus-wg-priv.age".publicKeys = with machines; [ copernicus.pubkey aristotle.pubkey machines.plato.pubkey ];

  # networkmanager
  "nm-home-net-config.age".publicKeys = with machines; [ copernicus.pubkey aristotle.pubkey machines.plato.pubkey ];

  # router configuration
  "r8000-config.cfg.age".publicKeys = [ machines.copernicus.pubkey machines.aristotle.pubkey machines.plato.pubkey ];

  # vaultwarden
  "vaultwarden-secret.age".publicKeys = all;

  # aerc
  "aerc-account-config.age".publicKeys = with machines; [ copernicus.pubkey aristotle.pubkey machines.plato.pubkey ];
}
