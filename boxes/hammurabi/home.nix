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

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = "eDP-1, 1920x1080, 0x0, 1.25";
      exec-once = [
        "eww open example"
        "emacs --daemon"
        "emacsclient -c"
      ];
      general = {
        gaps_in = "0";
        gaps_out = "0";
        border_size = "1";
        "col.active_border" = "rgba(ffffffff)";
        "col.inactive_border" = "rgba(000000ff)";
        resize_on_border = "false";
        allow_tearing = "false";
        layout = "dwindle";
      };
      decoration = {
        rounding = "0";
        rounding_power = "0";

        active_opacity = "1.0";
        inactive_opacity = "1.0";
        shadow.enabled = "false";
        blur.enabled = "false";
      };
      animations = {
        enabled = "yes";
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, easeInOutCubic, slide"
          "workspacesIn, 1, 1.21, easeInOutCubic, slide"
          "workspacesOut, 1, 1.94, easeInOutCubic, slide"
        ];
      };
      dwindle = {
        pseudotile = "true";
        preserve_split = "true";
      };
      master = {
        new_status = "master";
      };
      misc = {
        force_default_wallpaper = "0";
        disable_hyprland_logo = "true";
        vfr = "true";
      };
      input = {
        kb_layout = "us";
        kb_options = "caps:super";
        repeat_delay = "200";
        repeat_rate = "50";
        follow_mouse = "1";
        sensitivity = "0";
        touchpad = {
            natural_scroll = "false";
        };
      };
      gestures = {
        workspace_swipe = "true";
      };
      xwayland = {
        force_zero_scaling = "true";
      };
      bind = [
        "SUPER, Return, exec, emacsclient -n -e '(u:new-frame-with-vterm)'"
        "SUPER, Q, killactive,"
        "SUPER SHIFT, Q, exit,"
        "SUPER, Space, togglefloating,"
        "SUPER, D, exec, rofi -show drun"
        "SUPER, Z, exec, rbw-dmenu-list"
        "SUPER SHIFT, Z, exec, rbw-dmenu-list 2fa"
        "SUPER, V, togglesplit,"
        "SUPER, H, movefocus, l"
        "SUPER, L, movefocus, r"
        "SUPER, K, movefocus, u"
        "SUPER, J, movefocus, d"
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"
      ];
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };
  };
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
  programs.eww = {
    enable = true;
    configDir = ../../config/eww;
  };
  programs.foot = {
    enable = true;
  };
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
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
