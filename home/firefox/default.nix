{ lib, inputs, config, pkgs, home, ... }:

{
  programs.firefox = {
    enable = true;

    profiles = {
      "main" = {
        extensions = with inputs.firefox-addons; [
          bitwarden
        ];
      };
    };
  };
}
