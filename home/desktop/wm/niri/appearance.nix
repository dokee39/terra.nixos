{ lib, ... }:

{
  wayland.windowManager.niri.settings = {
    layout = {
      gaps = 12;
      background-color = "#232136ff";
      default-column-display = "tabbed";
      default-column-width = { };
      tab-indicator = {
        hide-when-single-tab = { };
        gap = 3;
        corner-radius = 999;
        gaps-between-tabs = 8;
        active-color = "#ea9a97ee";
        inactive-color = "#c5a3ffee";
        urgent-color = "#ea9d34ee";
      };

      focus-ring.off = { };
      border = {
        on = { };
        active-gradient._props = {
          from = "#b2ffffee";
          to = "#c5a3ff88";
          angle = 135;
        };
        inactive-gradient._props = {
          from = "#c5a3ff88";
          to = "#00000000";
          angle = 135;
        };
        urgent-gradient._props = {
          from = "#ea9d34ee";
          to = "#c5a3ff88";
          angle = 135;
        };
      };
    };

    cursor.hide-after-inactive-ms = 3000;

    blur = {
      passes = 3;
      offset = 3;
      noise = 0.03;
      saturation = 1.5;
    };

    # Apply general appearance before the app-specific window rules.
    _children = lib.mkBefore [
      {
        window-rule = {
          geometry-corner-radius = 12;
          clip-to-geometry = true;
          draw-border-with-background = false;
          opacity = 0.92;
          background-effect.blur = true;
        };
      }
      {
        window-rule = {
          match._props.is-active = false;
          opacity = 0.85;
        };
      }
      {
        window-rule = {
          match._props.is-window-cast-target = true;
          opacity = 1.0;
          border = {
            active-gradient._props = {
              from = "#b2ffffee";
              to = "#eb6f92ee";
              angle = 135;
            };
            inactive-gradient._props = {
              from = "#c5a3ff88";
              to = "#eb6f9288";
              angle = 135;
            };
            urgent-gradient._props = {
              from = "#ea9d34ee";
              to = "#eb6f92ee";
              angle = 135;
            };
          };
        };
      }
    ];
  };
}
