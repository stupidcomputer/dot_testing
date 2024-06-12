{ lib, config, pkgs, home, ... }:

{
  programs.rbw = {
    enable = true;
    settings = {
      base_url = "https://bitwarden.beepboop.systems";
      email = "bit@beepboop.systems";
      pinentry = pkgs.pinentry-gnome3;
    };
  };
}
