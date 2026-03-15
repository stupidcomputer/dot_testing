let
  machines = import ../common/machines.nix;

  userfacing = with machines; [
    aristotle.pubkey
    copernicus.pubkey
    hammurabi.pubkey
    plato.pubkey
  ];
  all = [ machines.theseus.pubkey ] ++ userfacing;
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

  # flasktrack secret
  "flasktrack-secret.age".publicKeys = all;

  # flagman settings
  "flagman-env.age".publicKeys = all;
}
