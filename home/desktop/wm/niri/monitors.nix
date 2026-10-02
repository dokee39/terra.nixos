{ lib, osConfig, ... }:

let
  monitors = osConfig.terra.desktop.monitors;
in
{
  wayland.windowManager.niri.settings._children =
    lib.mapAttrsToList (name: m: {
      output = {
        _args = [ name ];
        scale = m.scale;
      }
      // lib.optionalAttrs m.primary { focus-at-startup = { }; }
      // lib.optionalAttrs (m.transform.rotation != 0 || m.transform.flipped) {
        transform =
          if m.transform.flipped then
            "flipped" + lib.optionalString (m.transform.rotation != 0) "-${toString m.transform.rotation}"
          else
            toString m.transform.rotation;
      }
      // lib.optionalAttrs (m.position != null) { position._props = m.position; }
      // lib.optionalAttrs (m.mode != null) {
        mode = "${toString m.mode.width}x${toString m.mode.height}"
          + lib.optionalString (m.mode.refresh != null) "@${toString m.mode.refresh}";
      };
    }) monitors;
}
