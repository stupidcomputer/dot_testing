{ pkgs, machines, ... }:
{
  users.users.calendar-sync = {
    isNormalUser = true;
    home = "/home/calendar-sync";
    extraGroups = [ "nginx-data" ];
    openssh.authorizedKeys.keys = [
      machines.hammurabi.pubkey
    ];
  };

  services.nginx.virtualHosts = {
    "calendars.beepboop.systems" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        root = "/home/calendar-sync/nonexistent";
      };
      locations."/synchronized-calendars/" = {
        alias = "/home/calendar-sync/calendars/"; # trailing slash is important
      };
    };
  };

  system.activationScripts = {
    ensureCalendarDirectory = {
      text = ''
        ${pkgs.coreutils}/bin/mkdir -p /home/calendar-sync/calendars
        ${pkgs.coreutils}/bin/chown calendar-sync:nginx-data /home/calendar-sync
        ${pkgs.coreutils}/bin/chmod -R u=rwX,g=rwX,o= /home/calendar-sync
        ${pkgs.coreutils}/bin/chown -R calendar-sync:nginx-data /home/calendar-sync/calendars
        ${pkgs.coreutils}/bin/chmod -R u=rwX,g=rwX,o= /home/calendar-sync/calendars
        ${pkgs.coreutils}/bin/chmod g+s /home/calendar-sync/calendars
      '';
    };
  };
  
}
