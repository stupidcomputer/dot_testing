{ config, pkgs, ... }:

{
  home.username = "usr";
  home.homeDirectory = "/home/usr";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    neofetch
    wl-clipboard
    # for emacs
    emacsPackages.pdf-tools
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
    };
    extraConfig = ''
exec-once = eww open example
exec-once = foot --server
exec-once = emacs --daemon
exec-once = emacsclient
animations {
    enabled = yes

    bezier = easeOutQuint,0.23,1,0.32,1
    bezier = easeInOutCubic,0.65,0.05,0.36,1
    bezier = linear,0,0,1,1
    bezier = almostLinear,0.5,0.5,0.75,1.0
    bezier = quick,0.15,0,0.1,1

    animation = global, 1, 10, default
    animation = border, 1, 5.39, easeOutQuint
    animation = windows, 1, 4.79, easeOutQuint
    animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
    animation = windowsOut, 1, 1.49, linear, popin 87%
    animation = fadeIn, 1, 1.73, almostLinear
    animation = fadeOut, 1, 1.46, almostLinear
    animation = fade, 1, 3.03, quick
    animation = layers, 1, 3.81, easeOutQuint
    animation = layersIn, 1, 4, easeOutQuint, fade
    animation = layersOut, 1, 1.5, linear, fade
    animation = fadeLayersIn, 1, 1.79, almostLinear
    animation = fadeLayersOut, 1, 1.39, almostLinear
    animation = workspaces, 1, 1.94, easeInOutCubic, slide
    animation = workspacesIn, 1, 1.21, easeInOutCubic, slide
    animation = workspacesOut, 1, 1.94, easeInOutCubic, slide
}
dwindle {
    pseudotile = true
    preserve_split = true
}
master {
    new_status = master
}
misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
    vfr = true
}
input {
    kb_layout = us
    kb_options = caps:super
    repeat_delay = 200
    repeat_rate = 50
    follow_mouse = 1
    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    touchpad {
        natural_scroll = false
    }
}
gestures {
    workspace_swipe = true
}
xwayland {
    force_zero_scaling = true
}
$mainMod = SUPER
bind = $mainMod, Return, exec, footclient
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, Q, exit,
bind = $mainMod, Space, togglefloating,
bind = $mainMod, D, exec, rofi -show drun
bind = $mainMod, Z, exec, rbw-dmenu-list
bind = $mainMod SHIFT, Z, exec, rbw-dmenu-list 2fa
bind = $mainMod, V, togglesplit,
bind = $mainMod, H, movefocus, l
bind = $mainMod, L, movefocus, r
bind = $mainMod, K, movefocus, u
bind = $mainMod, J, movefocus, d
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

windowrule = suppressevent maximize, class:.*
windowrule = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
    '';
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
  };
}
