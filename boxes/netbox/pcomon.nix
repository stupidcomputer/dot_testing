{ config, pkgs, ... }:

let
  pcomon = (pkgs.callPackage ../../builds/pcomon.nix {});
in {
  users.users.pcomon = {
    isSystemUser = true;
    group = "pcomon";
  };

  users.groups.pcomon = {};

  systemd.services.pcomon = {
    serviceConfig.type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/mkdir -p /run/pcomon
      ${pkgs.coreutils}/bin/chown -R pcomon:pcomon /run/pcomon
      ${pcomon}/bin/pcomon ${config.age.secrets.pcomon-secrets-file.path}
    '';
  };

  systemd.timers.pcomon = {
    wantedBy = [ "timers.target" ];
    partOf = [ "pcomon.service" ];
    timerConfig.OnCalendar = "*:*:0/30";
  };
}
