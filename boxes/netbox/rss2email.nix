{ lib, config, pkgs, ... }:
{
  services.rss2email = {
    enable = true;
    to = "ryan@beepboop.systems";
    feeds = {
      "eff" = {
        url = "https://www.eff.org/rss/updates.xml";
      };
      "nixos" = {
        url = "https://nixos.org/blog/announcements-rss.xml";
      };
      "drewdevault" = {
        url = "https://drewdevault.com/blog/index.xml";
      };
      "nullprogram" = {
        url = "https://nullprogram.com/feed/";
      };
      "computersarebad" = {
        url = "https://computer.rip/rss.xml";
      };
    };
  };
}
