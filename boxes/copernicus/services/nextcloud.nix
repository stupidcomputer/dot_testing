{ lib, config, pkgs, ...}:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "nextcloud.beepboop.systems";
    config.adminpassFile = "/etc/nextcloud-admin";
    settings.overwriteprotocol = "https";
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks;
      phonetrack = pkgs.fetchNextcloudApp {
        sha256 = "sha256-V92f+FiS5vZEkq15A51pHoDpUOBfUOEVIcsXdP/rSMQ=";
        license = "agpl3Only";
        url = "https://github.com/julien-nc/phonetrack/releases/download/v0.8.1/phonetrack-0.8.1.tar.gz";
      };
    };
    extraAppsEnable = true;
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [ {
    addr = "10.100.0.2";
    port = 5028;
  } ];
}
