{ lib, config, pkgs, ...}:

{
  services.photoprism = {
    enable = true;
    originalsPath = "/var/lib/photoprism/originals";
    settings = {
      PHOTOPRISM_ADMIN_USER = "usr";
      PHOTOPRISM_ADMIN_PASSWORD = "usr";
      PHOTOPRISM_SITE_TITLE = "photos.beepboop.systems";
    };
  };
}
