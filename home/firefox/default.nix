{ lib, inputs, config, pkgs, home, ... }:

{
  programs.firefox = {
    enable = true;

    package = pkgs.firefox.override {
      extraPrefs = ''
        // automatically enable firefox extensions installed below
        lockPref("extensions.autoDisableScopes", 0);

        // enable the gruvbox-dark-theme theme
        lockPref("extensions.activeThemeID", "{eb8c4a94-e603-49ef-8e81-73d3c4cc04ff}");

        // make the interface compact
        lockPref("browser.uidensity", 1);

        // make the interface in the correct positions
        lockPref(
          "browser.uiCustomization.state",
          '{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":[],"nav-bar":["urlbar-container","back-button","forward-button","stop-reload-button","downloads-button","unified-extensions-button","addon_darkreader_org-browser-action","_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","umatrix_raymondhill_net-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["firefox-view-button","tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","addon_darkreader_org-browser-action","umatrix_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action","developer-button"],"dirtyAreaCache":["unified-extensions-area","nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar"],"currentVersion":20,"newElementCount":4}'
        );
      '';
    };

    profiles = {
      main = {
        extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
          bitwarden
          tridactyl
          umatrix
          violentmonkey
          darkreader
          gruvbox-dark-theme
        ];
      };
    };
  };
}
