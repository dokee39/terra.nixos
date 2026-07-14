{ lib, osConfig, ... }:

let
  monitors = osConfig.terra.desktop.monitors;

in
{
  programs.niri.settings.outputs =
    lib.mapAttrs (name: m:
      {
        scale = m.scale;
        transform = m.transform;
        focus-at-startup = m.primary;
      }
      // lib.optionalAttrs (m.position != null) { position = m.position; }
      // lib.optionalAttrs (m.mode != null) {
        mode = {
          width = m.mode.width;
          height = m.mode.height;
        } // lib.optionalAttrs (m.mode.refresh != null) { refresh = m.mode.refresh + 0.0; };
      }
    ) monitors;
}
