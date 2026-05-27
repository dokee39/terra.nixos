{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.niri.homeModules.niri
    ./monitors.nix
    ./appearance.nix
    ./input.nix
    ./binds.nix
    ./rules.nix
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
      clipboard.disable-primary = true;
      screenshot-path = "~/Pictures/screenshots/screenshot_%Y-%m-%d/screenshot_%Y-%m-%d_%H-%M-%S.png";
    };
  };

  xdg.configFile.niri-config.source = lib.mkForce (
    inputs.niri.lib.internal.validated-config-for pkgs config.programs.niri.package ''
      ${config.programs.niri.finalConfig}

      recent-windows {
          binds {
              Mod+Tab         { next-window; }
              Mod+Shift+Tab   { previous-window; }
              Mod+grave       { next-window     filter="app-id"; }
              Mod+Shift+grave { previous-window filter="app-id"; }
          }
      }

      blur {
          passes 3
          offset 3
          noise 0.03
          saturation 1.5
      }

      window-rule {
          background-effect {
              blur true
          }
      }

      layer-rule {
          match namespace="^(launcher)$"
          background-effect {
              blur true
              xray false
          }
          geometry-corner-radius 24
      }

      layer-rule {
          match namespace="^(notifications)$"
          background-effect {
              blur true
              xray false
          }
          block-out-from "screen-capture"
          geometry-corner-radius 18
      }
    ''
  );
}
