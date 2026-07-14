{ inputs, sources, osConfig, ... }:

{
  imports = [ sources.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    settings = {
      # ── Visual Theme ──
      theme = {
        builtin = "Rosé Pine";
        templates = {
          enable_builtin_templates = false;
          enable_community_templates = false;
        };
      };

      # ── Desktop Backdrop ──
      backdrop = {
        enabled = true;
        blur_intensity = 0.8;
      };

      # ── Wallpaper ──
      wallpaper.directory = "/home/dokee/Pictures/Wallpapers";

      # ── Top Bar ──
      bar.main = {
        enabled = true;
        background_opacity = 0.88;
        contact_shadow = true;
        radius = 0;
        margin_edge = 0.0;
        margin_ends = 0.0;
        start = [ "fuzzel" "space_10" "workspaces" ];
        center = [ "audio_visualizer_left" "clock" "audio_visualizer_right" ];
        end = [
          "ram"
          "space_20"
          "volume"
          "brightness"
          "battery"
          "control-center"
          "space_20"
          "notifications"
          "tray"
          "space_20"
          "session"
        ];
      };

      # ── Dock ──
      dock = {
        enabled = true;
        auto_hide = true;
        reserve_space = false;
        active_monitor_only = true;
        background_opacity = 0.5;
        launcher_icon = "apps";
        icon_size = 40;
        pinned = [ "kitty" ];
        show_dots = true;
        show_instance_count = false;
        inactive_opacity = 0.9;
        inactive_scale = 0.88;
      };

      # ── Desktop Widgets ──
      desktop_widgets = {
        enabled = false;
        schema_version = 1;
        grid = {
          visible = true;
          cell_size = 16;
          major_interval = 4;
        };
        widget_order = [ ];
        widget = { };
      };

      # ── Shell ──
      shell = {
        avatar_path = "/home/dokee/Pictures/dokee.png";
        font_family = "Maple Mono NF CN";
        corner_radius_scale = 1.5;
        date_format = "%A, %F";
        password_style = "random";
        polkit_agent = true;
        clipboard_enabled = false;
        telemetry_enabled = true;
        screen_time_enabled = true;
        settings_show_advanced = true;
        animation.speed = 1.5;

        panel = {
          borders = false;
          control_center_placement = "floating";
          session_placement = "floating";
          wallpaper_placement = "floating";
          open_near_click_control_center = true;
          open_near_click_session = true;
          open_near_click_wallpaper = true;
        };

        screen_corners = {
          enabled = true;
          size = 30;
        };
      };

      # ── Notification ──
      notification = {
        background_opacity = 0.5;
        scale = 0.85;
      };

      # ── On-Screen Display ──
      osd.background_opacity = 0.5;

      # ── Idle / Power Management ──
      idle = {
        behavior_order = [ "lock" "screen-off" "suspend" ];
        behavior = {
          lock = {
            enabled = true;
            action = "lock";
            timeout = 600;
          };
          "screen-off" = {
            enabled = true;
            action = "screen_off";
            timeout = 660;
          };
          suspend = {
            enabled = true;
            action = "suspend";
            timeout = 900;
            lock_before_suspend = true;
          };
        };
      };

      # ── Weather ──
      weather.auto_locate = true;

      # ── Widgets ──
      widget = {
        # Bar items (order matches bar layout: start → center → end)
        launcher = {
          glyph = "apps";
          scale = 1.2;
        };
        fuzzel = {
          type = "custom_button";
          command = "fuzzel";
          glyph = "apps";
          scale = 1.2;
        };

        workspaces = {
          hide_when_empty = true;
          font_weight = 700;
          empty_color = "primary";
          occupied_color = "primary";
          focused_color = "secondary";
        };

        clock = {
          anchor = true;
          format = "{:%H:%M:%S}";
          font_weight = 700;
          scale = 1.12;
        };
        audio_visualizer_left = {
          type = "audio_visualizer";
          color_1 = "secondary";
        };
        audio_visualizer_right = {
          type = "audio_visualizer";
          color_2 = "secondary";
        };

        ram.display = "graph";

        volume.scroll_step = 2;
        brightness.scroll_step = 2;
        control-center.glyph = "adjustments";

        notifications = { };
        tray = {
          drawer = true;
          drawer_columns = 5;
        };

        # Spacers
        space_10 = {
          type = "spacer";
          length = 10;
        };
        space_20.type = "spacer";
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 1;
        widget_order = [
          "lockscreen-login-box@${osConfig.terra.desktop.primaryMonitor}"
          "lockscreen-widget-0000000000000001"
        ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget = {
          "lockscreen-login-box@${osConfig.terra.desktop.primaryMonitor}" = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 957.0;
            output = osConfig.terra.desktop.primaryMonitor;
            rotation = 0.0;
            type = "login_box";
          };

          "lockscreen-widget-clock@${osConfig.terra.desktop.primaryMonitor}" = {
            box_height = 128.0;
            box_width = 384.0;
            cx = 1600.0;
            cy = 220.0;
            output = osConfig.terra.desktop.primaryMonitor;
            rotation = 0.0;
            type = "clock";
            settings = {
              background = false;
              clock_style = "digital";
              color = "primary";
              shadow = true;
            };
          };
        };
      };
    };
  };
}
