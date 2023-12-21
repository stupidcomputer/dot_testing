{ lib, config, pkgs, home, ... }:

{
  programs.firefox = {
    enable = true;

    profiles = {
      "main" = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
        ];
      };
    };
  };
}
