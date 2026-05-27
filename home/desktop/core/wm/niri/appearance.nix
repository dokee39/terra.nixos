{ ... }:

{
  programs.niri.settings = {
    layout = {
      gaps = 12;
      background-color = "#232136ff";
      default-column-display = "tabbed";
      tab-indicator = {
        hide-when-single-tab = true;
        gap = 3;
        corner-radius = 999;
        gaps-between-tabs = 8;
        active.color = "#ea9a97ee";
        inactive.color = "#c5a3ffee";
        urgent.color = "#ea9d34ee";
      };

      focus-ring.enable = false;
      border = {
        enable = true;
        width = 4;
        active.gradient = {
          from = "#b2ffffee";
          to = "#c5a3ff88";
          angle = 135;
        };
        inactive.gradient = {
          from = "#c5a3ff88";
          to = "#00000000";
          angle = 135;
        };
        urgent.gradient = {
          from = "#ea9d34ee";
          to = "#c5a3ff88";
          angle = 135;
        };
      };
    };

    overview.backdrop-color = "#232136ff";

    cursor = {
      hide-after-inactive-ms = 3000;
      hide-when-typing = false;
    };

    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 12.0;
          top-right = 12.0;
          bottom-left = 12.0;
          bottom-right = 12.0;
        };
        clip-to-geometry = true;
        draw-border-with-background = false;
        opacity = 0.92;
      }
      {
        matches = [ { is-active = false; } ];
        opacity = 0.85;
      }
      {
        matches = [ { is-window-cast-target = true; } ];
        opacity = 1.0;
        border = {
          active.gradient = {
            from = "#b2ffffee";
            to = "#eb6f92ee";
            angle = 135;
          };
          inactive.gradient = {
            from = "#c5a3ff88";
            to = "#eb6f9288";
            angle = 135;
          };
          urgent.gradient = {
            from = "#ea9d34ee";
            to = "#eb6f92ee";
            angle = 135;
          };
        };
      }
    ];
  };
}
