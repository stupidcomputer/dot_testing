let
  machines = import ../common/machines.nix;

  all = with machines; [
    copernicus.pubkey
    hammurabi.pubkey
    theseus.pubkey
  ];

  vnc = with machines; [
    copernicus.pubkey
    hammurabi.pubkey
    kant.pubkey
  ];
in {
  # mailserver
  "mailaccount.age".publicKeys = all;

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

  # home/school wifi network names
  "school-wifi-network-name.age".publicKeys = all;
  "home-wifi-network-name.age".publicKeys = all;

  # x11vnc password (vnc.nix)
  "vnc-passwd.age".publicKeys = vnc;
}
