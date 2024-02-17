{ lib, config, pkgs, ...}:

{
  services.sshd.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [];
}
