let
  machines = import ../common/machines.nix;

  all = with machines; [
    copernicus.pubkey
    hammurabi.pubkey
    theseus.pubkey
  ];
in {
  # mailserver
  "mailaccount.age".publicKeys = all;

  # wireguard
  "theseus.privkey.age".publicKeys = all;
  "copernicus.privkey.age".publicKeys = all;
  "hammurabi.privkey.age".publicKeys = all;

  "thesus-copernicus.psk.age".publicKeys = all;
  "copernicus-hammurabi.psk.age".publicKeys = all;
  "hammurabi-thesus.psk.age".publicKeys = all;

  "hammurabi-configuration.age".publicKeys = all;

  # networkmanager
  "nm-home-net-config.age".publicKeys = all;

  # router configuration
  "r8000-config.cfg.age".publicKeys = all;

  # vaultwarden
  "vaultwarden-secret.age".publicKeys = all;

  # aerc
  "aerc-account-config.age".publicKeys = all;

  # flasktrack secret
  "flasktrack-secret.age".publicKeys = all;

  # flagman settings
  "flagman-env.age".publicKeys = all;

  # guacamole user mapping
  "guac-user-mapping.xml.age".publicKeys = all;
}
