{ lib, config, pkgs, ...}:

{
  services.paperless = {
    enable = true;
    passwordFile = "/home/usr/wg-keys/paperless";
    address = "10.100.0.2";
    port = 6230;
    settings = {
      PAPERLESS_URL = "https://paperless.beepboop.systems";
    };
  };
}
