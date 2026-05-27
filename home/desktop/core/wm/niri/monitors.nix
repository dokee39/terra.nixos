{ lib, osConfig, ... }:

let
  monitors = osConfig.terra.desktop.monitors;

  transformMap = {
    "normal"       = { rotation = 0;   flipped = false; };
    "90"           = { rotation = 90;  flipped = false; };
    "180"          = { rotation = 180; flipped = false; };
    "270"          = { rotation = 270; flipped = false; };
    "flipped"      = { rotation = 0;   flipped = true;  };
    "flipped-90"   = { rotation = 90;  flipped = true;  };
    "flipped-180"  = { rotation = 180; flipped = true;  };
    "flipped-270"  = { rotation = 270; flipped = true;  };
  };
in
{
  programs.niri.settings.outputs =
    lib.mapAttrs (name: m:
      {
        scale = m.scale;
        transform = transformMap.${m.transform};
        focus-at-startup = m.primary;
      }
      // lib.optionalAttrs (m.position.niri != null) { position = m.position.niri; }
      // lib.optionalAttrs (m.mode != null) {
        mode = {
          width = m.mode.width;
          height = m.mode.height;
        } // lib.optionalAttrs (m.mode.refresh != null) { refresh = m.mode.refresh + 0.0; };
      }
    ) monitors;
}
