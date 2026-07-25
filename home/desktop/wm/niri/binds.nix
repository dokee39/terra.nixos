{ lib, ... }:

let
  b  = key: action:
    lib.nameValuePair key { repeat = false; inherit action; };
  br = key: action:
    lib.nameValuePair key { repeat = true; inherit action; };
  bc = cooldown: key: action:
    lib.nameValuePair key { repeat = true; cooldown-ms = cooldown; inherit action; };
  bl = key: action:
    lib.nameValuePair key { repeat = false; allow-when-locked = true; inherit action; };
  blr = key: action:
    lib.nameValuePair key { repeat = true; allow-when-locked = true; inherit action; };
  blc = cooldown: key: action:
    lib.nameValuePair key { repeat = true; allow-when-locked = true; cooldown-ms = cooldown; inherit action; };
in {
  programs.niri.settings.binds = lib.listToAttrs [
    # ── Launch ──────────────────────────────────────────────

    (b  "Mod+Q"       { spawn = [ "kitty" ]; })
    (b  "Mod+R"       { spawn = [ "fuzzel" ]; })
    (b  "Mod+E"       { spawn = [ "nautilus" "--new-window" ]; })
    (b  "Mod+P"       { spawn = [ "kitty" "--class" "clipse" "-e" "clipse" ]; })
    (b  "Mod+M"       { spawn = [ "kitty" "-T" "rmpc" "-e" "rmpc" ]; })
    (b  "Mod+N"       { spawn = [ "noctalia" "msg" "bar-toggle" ]; })
    (b  "Mod+Grave"   { spawn = [ "noctalia" "msg" "panel-toggle" "session" ]; })
    (b  "Mod+Shift+P" { spawn = [ "hyprpicker" "-a" ]; })

    # ── Window lifecycle ────────────────────────────────────

    (b  "Mod+C"      { close-window = {}; })
    (b  "Mod+Escape" { quit = {}; })

    # ── Layout: column size ─────────────────────────────────────

    (b  "Mod+V"       { toggle-window-floating = {}; })
    (b  "Mod+Shift+V" { switch-focus-between-floating-and-tiling = {}; })

    (b  "Mod+F"       { maximize-column = {}; })
    (b  "Mod+Shift+F" { fullscreen-window = {}; })
    (b  "Mod+Ctrl+F"  { maximize-window-to-edges = {}; })

    # ── Layout: column size ─────────────────────────────────────

    (br "Mod+Minus"        { set-column-width = [ "-10%" ]; })
    (br "Mod+Equal"        { set-column-width = [ "+10%" ]; })
    (br "Mod+Shift+Minus"  { set-window-height = [ "-10%" ]; })
    (br "Mod+Shift+Equal"  { set-window-height = [ "+10%" ]; })

    (br "Mod+Comma"        { set-column-width = [ "-10%" ]; })
    (br "Mod+Period"       { set-column-width = [ "+10%" ]; })
    (br "Mod+Shift+Comma"  { set-window-height = [ "-10%" ]; })
    (br "Mod+Shift+Period" { set-window-height = [ "+10%" ]; })

    # ── Tabs ────────────────────────────────────────────────────

    (b  "Mod+T"            { toggle-column-tabbed-display = {}; })
    (b  "Mod+BracketLeft"  { consume-or-expel-window-left = {}; })
    (b  "Mod+BracketRight" { consume-or-expel-window-right = {}; })

    # ── Window / Column nav ──────────────────────────────────────

    (br "Mod+Left"  { focus-column-left = {}; })
    (br "Mod+Right" { focus-column-right = {}; })
    (br "Mod+Up"    { focus-window-up-or-bottom = {}; })
    (br "Mod+Down"  { focus-window-down-or-top = {}; })
    (br "Mod+H"     { focus-column-left = {}; })
    (br "Mod+L"     { focus-column-right = {}; })
    (br "Mod+K"     { focus-window-up-or-bottom = {}; })
    (br "Mod+J"     { focus-window-down-or-top = {}; })
    (bc 100 "Mod+WheelScrollDown" { focus-window-down-or-column-right = {}; })
    (bc 100 "Mod+WheelScrollUp"   { focus-window-up-or-column-left = {}; })

    (br "Mod+Shift+Left"  { move-column-left = {}; })
    (br "Mod+Shift+Right" { move-column-right = {}; })
    (br "Mod+Shift+Up"    { move-window-up = {}; })
    (br "Mod+Shift+Down"  { move-window-down = {}; })
    (br "Mod+Shift+H"     { move-column-left = {}; })
    (br "Mod+Shift+L"     { move-column-right = {}; })
    (br "Mod+Shift+K"     { move-window-up = {}; })
    (br "Mod+Shift+J"     { move-window-down = {}; })
    (bc 100 "Mod+Shift+WheelScrollDown" { move-column-right = {}; })
    (bc 100 "Mod+Shift+WheelScrollUp"   { move-column-left = {}; })

    # -─ Monitor / Workspace nav ───────────────────────────────────────────

    (br "Mod+Ctrl+Left"  { focus-monitor-left = {}; })
    (br "Mod+Ctrl+Right" { focus-monitor-right = {}; })
    (br "Mod+Ctrl+Up"    { focus-workspace-up = {}; })
    (br "Mod+Ctrl+Down"  { focus-workspace-down = {}; })

    (br "Mod+Ctrl+H" { focus-monitor-left = {}; })
    (br "Mod+Ctrl+L" { focus-monitor-right = {}; })
    (br "Mod+Ctrl+K" { focus-workspace-up = {}; })
    (br "Mod+Ctrl+J" { focus-workspace-down = {}; })

    (br "Mod+Y" { focus-monitor-left = {}; })
    (br "Mod+O" { focus-monitor-right = {}; })
    (br "Mod+I" { focus-workspace-up = {}; })
    (br "Mod+U" { focus-workspace-down = {}; })

    (br "Mod+Page_Up"        { focus-workspace-up = {}; })
    (br "Mod+Page_Down"      { focus-workspace-down = {}; })
    (br "Mod+Shift+Page_Up"  { move-column-to-workspace-up = {}; })
    (br "Mod+Shift+Page_Down" { move-column-to-workspace-down = {}; })

    (br "Mod+Ctrl+Shift+Left"  { move-column-to-monitor-left = {}; })
    (br "Mod+Ctrl+Shift+Right" { move-column-to-monitor-right = {}; })
    (br "Mod+Ctrl+Shift+Up"    { move-column-to-workspace-up = {}; })
    (br "Mod+Ctrl+Shift+Down"  { move-column-to-workspace-down = {}; })

    (br "Mod+Ctrl+Shift+H" { move-column-to-monitor-left = {}; })
    (br "Mod+Ctrl+Shift+L" { move-column-to-monitor-right = {}; })
    (br "Mod+Ctrl+Shift+K" { move-column-to-workspace-up = {}; })
    (br "Mod+Ctrl+Shift+J" { move-column-to-workspace-down = {}; })

    (br "Mod+Shift+Y" { move-column-to-monitor-left = {}; })
    (br "Mod+Shift+O" { move-column-to-monitor-right = {}; })
    (br "Mod+Shift+I" { move-column-to-workspace-up = {}; })
    (br "Mod+Shift+U" { move-column-to-workspace-down = {}; })

    # ── Workspace by index ──────────────────────────────────

    (b  "Mod+1" { focus-workspace = 1; })
    (b  "Mod+2" { focus-workspace = 2; })
    (b  "Mod+3" { focus-workspace = 3; })
    (b  "Mod+4" { focus-workspace = 4; })
    (b  "Mod+5" { focus-workspace = 5; })
    (b  "Mod+6" { focus-workspace = 6; })
    (b  "Mod+7" { focus-workspace = 7; })
    (b  "Mod+8" { focus-workspace = 8; })
    (b  "Mod+9" { focus-workspace = 9; })
    (b  "Mod+0" { focus-workspace = 10; })

    (b  "Mod+Shift+1" { move-column-to-workspace = 1; })
    (b  "Mod+Shift+2" { move-column-to-workspace = 2; })
    (b  "Mod+Shift+3" { move-column-to-workspace = 3; })
    (b  "Mod+Shift+4" { move-column-to-workspace = 4; })
    (b  "Mod+Shift+5" { move-column-to-workspace = 5; })
    (b  "Mod+Shift+6" { move-column-to-workspace = 6; })
    (b  "Mod+Shift+7" { move-column-to-workspace = 7; })
    (b  "Mod+Shift+8" { move-column-to-workspace = 8; })
    (b  "Mod+Shift+9" { move-column-to-workspace = 9; })
    (b  "Mod+Shift+0" { move-column-to-workspace = 10; })

    # ── Overview ────────────────────────────────────────────

    (b  "Mod+Space" { toggle-overview = {}; })

    # ── Screenshots (niri built-in) ─────────────────────────

    (b  "Mod+F1" { screenshot = {}; })
    (b  "Mod+F3" { screenshot-window = {}; })
    (b  "Mod+F4" { screenshot-screen = {}; })

    # ── Volume ──────────────────────────────────────────────

    (blr     "XF86AudioRaiseVolume" { spawn = [ "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "2%+" ]; })
    (blr     "XF86AudioLowerVolume" { spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "2%-" ]; })
    (bl      "XF86AudioMute"        { spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ]; })

    (blr     "Mod+X"       { spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "2%-" ]; })
    (blr     "Mod+Shift+X" { spawn = [ "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "2%+" ]; })
    (bl      "Mod+Z"       { spawn = [ "mute-pause" ]; })
    (bl      "Mod+Shift+Z" { spawn = [ "rmpc" "togglepause" ]; })

    # ── Brightness ──────────────────────────────────────────

    (blc 50 "XF86MonBrightnessDown" { spawn = [ "noctalia" "msg" "brightness-down" "current" "2" ]; })
    (blc 50 "XF86MonBrightnessUp"   { spawn = [ "noctalia" "msg" "brightness-up" "current" "2" ]; })

    (blc 50 "Mod+B"       { spawn = [ "noctalia" "msg" "brightness-down" "current" "2" ]; })
    (blc 50 "Mod+Shift+B" { spawn = [ "noctalia" "msg" "brightness-up" "current" "2" ]; })
  ];
}
