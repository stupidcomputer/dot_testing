{ lib, ... }:
{
  services.paperless = {
    enable = true;

    # we're only hosting on loopback, so this is safe
    passwordFile = builtins.toFile "admin_pass" "admin";
    address = "127.0.0.1"; # see above comment
    port = 5000;
  };

  # start paperless manually so as to not destroy battery life
  systemd.services = {
    paperless-scheduler.wantedBy = lib.mkForce [];
    redis-paperless.wantedBy = lib.mkForce [];
    redis-paperless.after = lib.mkForce [];
  };
}
