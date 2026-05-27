{ ... }:

{
  programs.niri.settings.binds = {
    # ── Launch ──────────────────────────────────────────────

    "Mod+Q".action.spawn = [ "kitty" ];
    "Mod+R".action.spawn = [ "fuzzel" ];
    "Mod+E".action.spawn = [ "nautilus" "--new-window" ];
    "Mod+Y".action.spawn = [ "kitty" "--class" "clipse" "-e" "clipse" ];
    "Mod+F8".action.spawn = [ "kitty" "-T" "rmpc" "-e" "rmpc" ];

    # ── Window lifecycle ────────────────────────────────────

    "Mod+C".action.close-window = {};
    "Mod+Escape".action.quit = {};

    # ── Layout: column size ─────────────────────────────────────

    "Mod+V".action.toggle-window-floating = {};
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = {};

    "Mod+F".action.maximize-column = {};
    "Mod+Shift+F".action.fullscreen-window = {};
    "Mod+Ctrl+F".action.maximize-window-to-edges = {};

    # ── Layout: column size ─────────────────────────────────────

    "Mod+Minus".action.set-column-width = [ "-10%" ];
    "Mod+Equal".action.set-column-width = [ "+10%" ];
    "Mod+Shift+Minus".action.set-window-height = [ "-10%" ];
    "Mod+Shift+Equal".action.set-window-height = [ "+10%" ];

    "Mod+Comma".action.set-column-width = [ "-10%" ];
    "Mod+Period".action.set-column-width = [ "+10%" ];
    "Mod+Shift+Comma".action.set-window-height = [ "-10%" ];
    "Mod+Shift+Period".action.set-window-height = [ "+10%" ];

    # ── Tabs ────────────────────────────────────────────────────

    "Mod+T".action.toggle-column-tabbed-display = {};
    "Mod+BracketLeft".action.consume-or-expel-window-left = {};
    "Mod+BracketRight".action.consume-or-expel-window-right = {};

    # ── Focus movement ──────────────────────────────────────

    "Mod+Left".action.focus-column-left = {};
    "Mod+Right".action.focus-column-right = {};
    "Mod+Up".action.focus-window-up = {};
    "Mod+Down".action.focus-window-down = {};
    "Mod+H".action.focus-column-left = {};
    "Mod+L".action.focus-column-right = {};
    "Mod+K".action.focus-window-up = {};
    "Mod+J".action.focus-window-down = {};

    # ── Window / column move ────────────────────────────────

    "Mod+Shift+Left".action.move-column-left = {};
    "Mod+Shift+Right".action.move-column-right = {};
    "Mod+Shift+Up".action.move-window-up = {};
    "Mod+Shift+Down".action.move-window-down = {};
    "Mod+Shift+H".action.move-column-left = {};
    "Mod+Shift+L".action.move-column-right = {};
    "Mod+Shift+K".action.move-window-up = {};
    "Mod+Shift+J".action.move-window-down = {};

    "Mod+Ctrl+Shift+Left".action.move-column-to-monitor-left = {};
    "Mod+Ctrl+Shift+Right".action.move-column-to-monitor-right = {};
    "Mod+Ctrl+Shift+Up".action.move-column-to-monitor-up = {};
    "Mod+Ctrl+Shift+Down".action.move-column-to-monitor-down = {};
    "Mod+Ctrl+Shift+H".action.move-column-to-monitor-left = {};
    "Mod+Ctrl+Shift+L".action.move-column-to-monitor-right = {};
    "Mod+Ctrl+Shift+K".action.move-column-to-monitor-up = {};
    "Mod+Ctrl+Shift+J".action.move-column-to-monitor-down = {};

    # ── Monitor focus ───────────────────────────────────────────

    "Mod+Ctrl+Left".action.focus-monitor-left = {};
    "Mod+Ctrl+Right".action.focus-monitor-right = {};
    "Mod+Ctrl+H".action.focus-monitor-left = {};
    "Mod+Ctrl+L".action.focus-monitor-right = {};

    # ── Workspace by index ──────────────────────────────────

    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;
    "Mod+0".action.focus-workspace = 10;

    "Mod+Shift+1".action.move-column-to-workspace = 1;
    "Mod+Shift+2".action.move-column-to-workspace = 2;
    "Mod+Shift+3".action.move-column-to-workspace = 3;
    "Mod+Shift+4".action.move-column-to-workspace = 4;
    "Mod+Shift+5".action.move-column-to-workspace = 5;
    "Mod+Shift+6".action.move-column-to-workspace = 6;
    "Mod+Shift+7".action.move-column-to-workspace = 7;
    "Mod+Shift+8".action.move-column-to-workspace = 8;
    "Mod+Shift+9".action.move-column-to-workspace = 9;
    "Mod+Shift+0".action.move-column-to-workspace = 10;

    # ── Workspace nav ───────────────────────────────────────────

    "Mod+U".action.focus-workspace-down = {};
    "Mod+I".action.focus-workspace-up = {};
    "Mod+Page_Down".action.focus-workspace-down = {};
    "Mod+Page_Up".action.focus-workspace-up = {};
    "Mod+WheelScrollDown".action.focus-workspace-down = {};
    "Mod+WheelScrollDown".cooldown-ms = 150;
    "Mod+WheelScrollUp".action.focus-workspace-up = {};
    "Mod+WheelScrollUp".cooldown-ms = 150;

    # ── Overview ────────────────────────────────────────────

    "Mod+O".action.toggle-overview = {};
    "Mod+O".repeat = false;

    # ── Screenshots (niri built-in) ─────────────────────────

    "Mod+F1".action.screenshot = {};
    "Mod+F3".action.screenshot-window = {};
    "Mod+F4".action.screenshot-screen = {};

    # ── Volume ──────────────────────────────────────────────

    "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "2%+" ];
    "XF86AudioRaiseVolume".allow-when-locked = true;
    "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "2%-" ];
    "XF86AudioLowerVolume".allow-when-locked = true;
    "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
    "XF86AudioMute".allow-when-locked = true;

    "Mod+X".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "2%-" ];
    "Mod+Shift+X".action.spawn = [ "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "2%+" ];
    "Mod+Z".action.spawn = [ "mute-pause" ];
    "Mod+Shift+Z".action.spawn = [ "rmpc-control" "togglepause" ];

    # ── Brightness ──────────────────────────────────────────

    "XF86MonBrightnessDown".action.spawn = [ "brightd" "ctl" "dec" "all" "2" ];
    "XF86MonBrightnessDown".allow-when-locked = true;
    "XF86MonBrightnessUp".action.spawn = [ "brightd" "ctl" "inc" "all" "2" ];
    "XF86MonBrightnessUp".allow-when-locked = true;

    "Mod+B".action.spawn = [ "brightd" "ctl" "dec" "all" "2" ];
    "Mod+Shift+B".action.spawn = [ "brightd" "ctl" "inc" "all" "2" ];
  };
}
