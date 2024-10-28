{ lib, config, pkgs, ...}:

{
  services.photoprism = {
    enable = true;
    originalsPath = "/var/lib/photoprism/originals";
    passwordFile = "/home/usr/wg-keys/photoprism-password";
    address = "10.100.0.2";
    settings = {
      PHOTOPRISM_ADMIN_USER = "usr";
      PHOTOPRISM_SITE_TITLE = "photos.beepboop.systems";
      PHOTOPRISM_SITE_URL = "https://photos.beepboop.systems";
      PHOTOPRISM_DEFAULT_LOCALE = "en";
    };
  };
}
