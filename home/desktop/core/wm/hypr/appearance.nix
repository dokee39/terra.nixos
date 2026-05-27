{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    general = {
      border_size = 4;
      gaps_out = 16;

      "col.active_border" = "rgba(b2ffffee) rgba(c5a3ffee) 45deg";
      "col.inactive_border" = "rgba(59595900)";

      resize_on_border = true;

      snap = {
        enabled = true;
        respect_gaps = true;
      };
    };

    decoration = {
      rounding = 12;
      rounding_power = 5;

      active_opacity = 0.90;
      inactive_opacity = 0.82;

      dim_inactive = true;
      dim_strength = 0.025;
      dim_special = 0.36;
      dim_around = 0.25;

      blur = {
        size = 1;
        passes = 5;
        noise = 0.0;
        vibrancy_darkness = 0.6;

        xray = true;
        ignore_opacity = false;

        popups = true;
        input_methods = true;
      };

      shadow = {
        range = 66;
        render_power = 4;
        ignore_window = false;
        color = "rgba(8077a8ee)";
        offset = "6 6";
        scale = 0.9925;
      };
    };

    animations = {
      bezier = [
        "easeOutQuint, 0.23, 1, 0.32, 1"
        "linear, 0, 0, 1, 1"
        "almostLinear, 0.5, 0.5, 0.75, 1.0"
        "quick, 0.15, 0, 0.1, 1"
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
        "border, 1, 10, default"
        "borderangle, 1, 24, default"
        "workspaces, 1, 1.94, almostLinear, fade"
        "workspacesIn, 1, 1.21, almostLinear, fade"
        "workspacesOut, 1, 1.94, almostLinear, fade"
      ];
    };

    group = {
      drag_into_group = 2;

      "col.border_active" = "rgba(ea9a97ee) rgba(c5a3ffee) 45deg";
      "col.border_inactive" = "rgba(59595900)";

      groupbar = {
        gaps_in = 3;
        gaps_out = 3;
        keep_upper_gap = false;

        height = 20;
        indicator_gap = 2;
        indicator_height = 5;

        text_color = "rgba(393552ff)";
        font_size = 16;
        font_weight_active = "bold";

        rounding = 20;

        "col.active" = "rgba(ea9a97ee)";
        "col.inactive" = "rgba(ebbcbacc)";
      };
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
      special_scale_factor = 0.9;
    };

    master = {
      new_status = "master";
    };

    misc = {
      font_family = "Maple Mono NF CN";

      background_color = "rgba(232136ff)";
      force_default_wallpaper = 0;

      "col.splash" = "rgba(232136ff)";
      splash_font_family = "LXGW Bright";

      vrr = 2;
      mouse_move_enables_dpms = true;

      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;

      allow_session_lock_restore = true;
      middle_click_paste = false;
      anr_missed_pings = 1;
    };

    xwayland = {
      force_zero_scaling = true;
    };

    render = {
      direct_scanout = 2;
    };

    cursor = {
      min_refresh_rate = 60;
      hotspot_padding = 2;
      inactive_timeout = 5;
    };
  };
}
