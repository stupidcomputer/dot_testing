let
  machines = import ../lib/machines.nix;
  server-netbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvinRGdd9GuiPnZYBQPzraXeBxeStwakzmtfzNNpDxy";

  userfacing = with machines; [
    aristotle.pubkey
    copernicus.pubkey
    hammurabi.pubkey
    plato.pubkey
  ];
  all = [ server-netbox ] ++ userfacing;
in {
  # mailserver
  "mailaccount.age".publicKeys = all;

  # wireguard
  "netbox-wg-priv.age".publicKeys = all;
  "copernicus-wg-priv.age".publicKeys = userfacing;

  # networkmanager
  "nm-home-net-config.age".publicKeys = userfacing;

  # router configuration
  "r8000-config.cfg.age".publicKeys = userfacing;

  # vaultwarden
  "vaultwarden-secret.age".publicKeys = all;

  # aerc
  "aerc-account-config.age".publicKeys = userfacing;
}
