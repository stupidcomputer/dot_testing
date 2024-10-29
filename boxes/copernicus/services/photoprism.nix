{ lib, config, pkgs, ...}:

{
  services.photoprism = {
    enable = true;
    originalsPath = "/var/lib/photoprism/originals";
    address = "10.100.0.2";
    settings = {
      PHOTOPRISM_ADMIN_USER = "usr";
      PHOTOPRISM_ADMIN_PASSWORD = "testing"; # THIS IS AN INITIAL PASSWORD -- changed later
      PHOTOPRISM_SITE_TITLE = "photos.beepboop.systems";
      PHOTOPRISM_SITE_URL = "https://photos.beepboop.systems";
      PHOTOPRISM_DEFAULT_LOCALE = "en";
    };
  };
}
