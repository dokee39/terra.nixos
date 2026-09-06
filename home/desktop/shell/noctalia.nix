{ config, lib, osConfig, ... }:

let
  homeDir = config.home.homeDirectory;

  hasBattery = osConfig.terra.hardware.hasBattery;

  desktopCfg = osConfig.terra.desktop;
  primaryMonitor = desktopCfg.primaryMonitor;
  secondaryMonitors = builtins.filter (name: name != primaryMonitor)
    (builtins.attrNames desktopCfg.monitors);
in {
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
      wallpaper.directory = "${homeDir}/Pictures/Wallpapers/comic";

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
        ] ++ lib.optional hasBattery "battery" ++ [
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
        margin_edge = 24;
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
        avatar_path = "${homeDir}/Pictures/dokee.png";
        font_family = "Maple Mono NF CN";
        corner_radius_scale = 1.5;
        date_format = "%A, %F";
        password_style = "default";
        polkit_agent = true;
        clipboard_enabled = false;
        telemetry_enabled = true;
        screen_time_enabled = true;
        settings_show_advanced = true;
        animation.speed = 1.75;

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
          enabled = false;
          size = 30;
        };
      };

      # ── Notification ──
      notification = {
        background_opacity = 0.5;
        scale = 0.85;
      };

      # ── On-Screen Display ──
      osd = {
        background_opacity = 0.5;
        position = "top_right";
        kinds = {
          keyboard_layout = false;
          media = false;
        };
      };

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

      location.auto_locate = false;
      weather.enabled = false;
      brightness.enable_ddcutil = true;
      battery.warning_threshold = 36;
      control_center.hidden_tabs = lib.optional (!hasBattery) "power";

      # ── Widgets ──
      widget = {
        # Bar items (order matches bar layout: start → center → end)
        launcher = {
          glyph = "apps";
          scale = 1.2;
        };
        fuzzel = {
          type = "custom_button";
          actions.left = "exec fuzzel";
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

        ram.visualization = "graph";

        volume.actions = {
          scroll_up = "volume-up 2%";
          scroll_down = "volume-down 2%";
        };
        brightness.actions = {
          scroll_up = "brightness-up 2%";
          scroll_down = "brightness-down 2%";
        };
        battery.hide_when_full = true;

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
          "lockscreen-login-box@${primaryMonitor}"
          "lockscreen-widget-clock@${primaryMonitor}"
        ] ++ map (name: "lockscreen-login-box@${name}") secondaryMonitors;

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget = {
          "lockscreen-login-box@${primaryMonitor}" = {
            enabled = true;
            box_height = 70.0;
            box_width = 400.0;
            cx = 960.0;
            cy = 957.0;
            placement_width = 1920.0;
            placement_height = 1080.0;
            output = primaryMonitor;
            rotation = 0.0;
            type = "login_box";
            settings = {
              layout = "compact";
              center_password_text = true;
              show_login_button = false;
            };
          };

          "lockscreen-widget-clock@${primaryMonitor}" = {
            enabled = true;
            box_height = 128.0;
            box_width = 384.0;
            cx = 1600.0;
            cy = 220.0;
            placement_width = 1920.0;
            placement_height = 1080.0;
            output = primaryMonitor;
            rotation = 0.0;
            type = "clock";
            settings = {
              background = false;
              clock_style = "digital";
              color = "primary";
              shadow = true;
            };
          };
        } // builtins.listToAttrs (map (name:
          # Noctalia recreates missing login boxes; keep secondary ones explicitly disabled.
          lib.nameValuePair "lockscreen-login-box@${name}" {
            type = "login_box";
            output = name;
            enabled = false;
          }
        ) secondaryMonitors);
      };
    };
  };
}
