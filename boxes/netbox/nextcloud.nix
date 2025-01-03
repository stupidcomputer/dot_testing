{ config, pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    https = true;
    package = pkgs.nextcloud30;
    hostName = "nextcloud.beepboop.systems";
    config.adminpassFile = config.age.secrets.nextcloud-passwd.path;
    settings.overwriteprotocol = "https";
    extraApps = {
      phonetrack = pkgs.fetchNextcloudApp {
        sha256 = "sha256-zQt+3t86HZJVT/wiETHkPdTwV6Qy+iNkH3/THtTe1Xs=";
        license = "agpl3Only";
        url = "https://github.com/julien-nc/phonetrack/releases/download/v0.8.1/phonetrack-0.8.1.tar.gz";
      };
    };
    extraAppsEnable = true;
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
    forceSSL = true;
    enableACME = true;
  };
}
