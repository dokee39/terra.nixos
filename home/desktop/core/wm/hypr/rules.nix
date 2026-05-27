{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    layerrule = [
      # waybar
      "match:namespace waybar, blur on, ignore_alpha 0, xray 1"
      # wlogout
      "match:namespace logout_dialog, blur on, dim_around on, ignore_alpha 0, xray 1, above_lock 1"
      # tofi
      "match:namespace launcher, blur on, dim_around on, ignore_alpha 0, xray 1"
      # mako
      "match:namespace notifications, blur on, ignore_alpha 0, xray 1"
    ];

    windowrule = [
      # pinned window style
      "match:pin 1, border_color rgba(f6c177ee) rgba(f6c177ee), border_size 3"

      # picture-in-picture window style
      "match:title (Picture-in-picture), opacity 1.0 override 1.0 override 1.0 override, float on, pin on, keep_aspect_ratio on"

      # Ignore maximize requests from apps.
      "suppress_event maximize, match:class .*"

      # Fix some dragging issues with XWayland
      "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"

      # app-specific tiling/floating
      "tile on, match:class ^(steam|Aseprite)$"
      "float on, match:class ^(qq|QQ|wechat|org.telegram.desktop|sxiv|imv|org.gnome.Loupe|rustdesk|tlpui|lxappearance|qt6ct|org.fcitx.fcitx5-config-qt|org.gnome.Nautilus)$"
      "match:initial_title ^(wechat)$, match:xwayland 1, match:float 1, opacity 1.0 override 1.0 override 1.0 override, no_blur on, no_shadow on, rounding 0, border_size 0"

      # qView / Seahorse (Passwords and Keys)
      "float on, match:class ^(com.interversehq.qView|org.gnome.seahorse.Application)$, float on, size monitor_h monitor_h*0.618"

      # kitty: pulsemixer / bluetui / impala / rmpc
      "match:class (kitty), match:initial_title ^(pulsemixer|bluetui|impala|rmpc)$, float on, center on, size monitor_h monitor_h*0.618"

      # kitty: btop
      "match:class (kitty), match:initial_title ^(btop)$, float on, center on, size monitor_w*0.85 monitor_h*0.85"

      # dialogs
      "match:class (google-chrome), match:title (Print), float on, center on"
      "match:class (electron), match:title (Location), float on, center on, size monitor_h monitor_h*0.618"
      "match:title ^(Select|Open)(.*)$, float on, center on, size monitor_h monitor_h*0.618"

      # clipse
      "match:class (clipse), float on, center on, size 622 652, stay_focused on"

      # rog-control-center
      "match:class (rog-control-center), float on, center on, size monitor_h monitor_h*0.618"

      # vscode
      "match:initial_title (Visual Studio Code), opacity 0.86 override 0.78 override 0.88 override"

      # steam games
      "match:class ^steam_app_[0-9]+$, fullscreen on, idle_inhibit fullscreen"
    ];
  };
}
