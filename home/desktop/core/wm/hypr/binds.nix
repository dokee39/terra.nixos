{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$terminal" = "kitty";
    "$workspacectl" = "workspacectl";

    bind = [
      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, exec, $workspacectl switch 1"
      "$mainMod, 2, exec, $workspacectl switch 2"
      "$mainMod, 3, exec, $workspacectl switch 3"
      "$mainMod, 4, exec, $workspacectl switch 4"
      "$mainMod, 5, exec, $workspacectl switch 5"
      "$mainMod, 6, exec, $workspacectl switch 6"
      "$mainMod, 7, exec, $workspacectl switch 7"
      "$mainMod, 8, exec, $workspacectl switch 8"
      "$mainMod, 9, exec, $workspacectl switch 9"
      "$mainMod, 0, exec, $workspacectl switch 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, exec, $workspacectl move 1"
      "$mainMod SHIFT, 2, exec, $workspacectl move 2"
      "$mainMod SHIFT, 3, exec, $workspacectl move 3"
      "$mainMod SHIFT, 4, exec, $workspacectl move 4"
      "$mainMod SHIFT, 5, exec, $workspacectl move 5"
      "$mainMod SHIFT, 6, exec, $workspacectl move 6"
      "$mainMod SHIFT, 7, exec, $workspacectl move 7"
      "$mainMod SHIFT, 8, exec, $workspacectl move 8"
      "$mainMod SHIFT, 9, exec, $workspacectl move 9"
      "$mainMod SHIFT, 0, exec, $workspacectl move 10"

      # Move focus with mainMod + arrow keys
      "$mainMod, left,  movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up,    movefocus, u"
      "$mainMod, down,  movefocus, d"
      "$mainMod SHIFT, left,  movewindow, l"
      "$mainMod SHIFT, right, movewindow, r"
      "$mainMod SHIFT, up,    movewindow, u"
      "$mainMod SHIFT, down,  movewindow, d"
      "$mainMod, H, movefocus, l"
      "$mainMod, L, movefocus, r"
      "$mainMod, K, movefocus, u"
      "$mainMod, J, movefocus, d"
      "$mainMod SHIFT, H, movewindow, l"
      "$mainMod SHIFT, L, movewindow, r"
      "$mainMod SHIFT, K, movewindow, u"
      "$mainMod SHIFT, J, movewindow, d"

      "$mainMod, bracketleft,  movecurrentworkspacetomonitor, l"
      "$mainMod, bracketright, movecurrentworkspacetomonitor, r"

      # Example special workspace (scratchpad)
      "$mainMod, S,       togglespecialworkspace, magic"
      "$mainMod SHIFT, S, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mainMod + scroll
      "$mainMod, mouse_down, workspace, e-1"
      "$mainMod, mouse_up,   workspace, e+1"

      # main
      "$mainMod, Q,       exec, $terminal"
      "$mainMod SHIFT, Q, exec, [fullscreen] terminal"
      "$mainMod, C,       exec, hyprkill"
      "$mainMod SHIFT, C, exec, hyprkill --force"
      "$mainMod, escape,  exec, hyprctl dispatch exit"
      "$mainMod, E,       exec, [float] nautilus --new-window"
      "$mainMod, V,       togglefloating,"
      "$mainMod, R,       exec, tofi-drun --drun-launch=true"
      "$mainMod, T,       togglesplit,"
      "$mainMod, F,       fullscreen, 0"
      "$mainMod SHIFT, F, fullscreenstate, 2 1"
      "$mainMod, P,       pin"

      # group
      "$mainMod, G,         togglegroup,"
      "$mainMod SHIFT, G,   moveoutofgroup,"
      "$mainMod, TAB,       changegroupactive, f"
      "$mainMod SHIFT, TAB, changegroupactive, b"

      "$mainMod, W,  exec, pkill -USR1 waybar"
      "$mainMod, I,  exec, hyprpicker -a"
      "$mainMod, Y,  exec, $terminal --class clipse -e clipse"
      "$mainMod, F1, exec, screenshot area"
      "$mainMod, F2, exec, screenshot show"
      "$mainMod, F3, exec, screenshot window"
      "$mainMod, F4, exec, screenshot monitor"
      "$mainMod, F8, exec, $terminal -T rmpc -e rmpc"
    ];

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindel = [
      # volume & brightness
      ", XF86MonBrightnessDown, exec, brightd ctl dec all 2"
      ", XF86MonBrightnessUp,   exec, brightd ctl inc all 2"
      "$mainMod, B,             exec, brightd ctl dec all 2"
      "$mainMod SHIFT, B,       exec, brightd ctl inc all 2"

      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"
      "$mainMod, X,            exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      "$mainMod SHIFT, X,      exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"
    ];

    bindl = [
      ", XF86AudioMute,   exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      "$mainMod, Z,       exec, mute-pause"
      "$mainMod SHIFT, Z, exec, rmpc-control togglepause"
    ];
  };
}
