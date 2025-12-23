{ config, pkgs, ... }:

{
  home.username = "usr";
  home.homeDirectory = "/home/usr";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    neofetch
    wl-clipboard
    # for emacs
    ghostscript
    gnuplot
    ical2orgpy
    texliveFull
    # for cmus
    ncpamixer
    bluetuith
    kid3-cli
  ];

  programs.rbw = {
    enable = true;
    settings = {
      base_url = "https://bitwarden.beepboop.systems";
      identity_url = "https://bitwarden.beepboop.systems";
      email = "bit@beepboop.systems";
      pinentry = pkgs.pinentry-gnome3;
    };
  };
  programs.htop = {
    enable = true;
  };
  programs.cmus = {
    enable = true;
    extraConfig = ''
set show_current_bitrate=true
set pause_on_output_change=true
set status_display_program=cmus-status-update
    '';
  };
  programs.rofi = {
    enable = true;
  };
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
#      auctex
#      evil
#      evil-collection
#      org-evil
#      org-journal
#      org-drill
#      elfeed
#      pdf-tools
#      vterm
#      nix-mode
#      python-mode
#      gruvbox-theme
    ];
  };
}
