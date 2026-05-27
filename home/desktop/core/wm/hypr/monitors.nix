{ lib, osConfig, ... }:

let
  monitors = osConfig.terra.desktop.monitors;
  prim = osConfig.terra.desktop.primaryMonitor;

  transformMap = {
    "normal" = 0; "90" = 1; "180" = 2; "270" = 3;
    "flipped" = 4; "flipped-90" = 5; "flipped-180" = 6; "flipped-270" = 7;
  };

  fmtMode = m:
    if m.mode == null then "preferred"
    else "${toString m.mode.width}x${toString m.mode.height}"
      + lib.optionalString (m.mode.refresh != null) "@${toString m.mode.refresh}";

  fmtLine = name: m:
    "${name},${fmtMode m},${if m.position.hyprland != null then m.position.hyprland else "auto"},${toString m.scale},transform,${toString transformMap.${m.transform}}";
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mapAttrsToList fmtLine monitors;

    workspace =
      [ "r[1-10], monitor:${prim}" "1, monitor:${prim}, default:true" ]
      ++ builtins.concatLists (
        lib.imap0 (i: name: [
          "r[${toString (((i + 1) * 10) + 1)}-${toString ((i + 2) * 10)}], monitor:${name}"
          "${toString (((i + 1) * 10) + 1)}, monitor:${name}, default:true"
        ]) (builtins.filter (n: !monitors.${n}.primary) (builtins.attrNames monitors))
      );
  };
}
