{ ... }:

{
  wayland.windowManager.niri.settings = {
    _children = map (rule: { window-rule = rule; }) [
      # ── VSCode opacity (overrides global) ──
      {
        match._props = { title = "Visual Studio Code"; is-active = false; };
        opacity = 0.80;
      }
      {
        match._props = { title = "Visual Studio Code"; is-active = true; };
        opacity = 0.88;
      }

      # ── Explicitly force tile (apps that might auto-float) ──
      {
        match._props.app-id = "^(steam|Aseprite)$";
        open-floating = false;
      }

      # ── Float: broad class list ──
      {
        match._props.app-id = "^(qq|QQ|wechat|org\\.telegram\\.desktop|sxiv|imv|org\\.gnome\\.Loupe|rustdesk|tlpui|lxappearance|qt6ct|org\\.fcitx\\.fcitx5-config-qt|org\\.gnome\\.Nautilus)$";
        open-floating = true;
      }

      # ── kitty: pulsemixer / bluetui / impala / rmpc ──
      {
        match._props = {
          app-id = "kitty";
          title = "^(pulsemixer|bluetui|impala|rmpc)$";
        };
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── kitty: btop ──
      {
        match._props = { app-id = "kitty"; title = "^btop$"; };
        open-floating = true;
        default-column-width = { proportion = 0.85; };
        default-window-height = { proportion = 0.85; };
      }

      # ── clipse ──
      {
        match._props.app-id = "clipse";
        open-floating = true;
        default-column-width = { fixed = 622; };
        default-window-height = { fixed = 652; };
      }

      # ── WeChat: no decorations ──
      {
        match._props.app-id = "wechat";
        open-floating = true;
        opacity = 1.0;
        clip-to-geometry = true;
      }

      # ── Select / Open dialogs ──
      {
        match._props.title = "^(Select|Open)";
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Chrome print dialog ──
      {
        match._props = { app-id = "google-chrome"; title = "Print"; };
        open-floating = true;
      }

      # ── Picture-in-Picture ──
      {
        match._props.title = "Picture-in-picture";
        open-floating = true;
        opacity = 1.0;
      }

      # ── qView / Seahorse ──
      {
        match._props.app-id = "(com\\.interversehq\\.qView|org\\.gnome\\.seahorse\\.Application)";
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Electron location dialog ──
      {
        match._props = { app-id = "electron"; title = "Location"; };
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── rog-control-center ──
      {
        match._props.app-id = "rog-control-center";
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Steam games ──
      {
        match._props.app-id = "^steam_app_[0-9]+$";
        open-fullscreen = true;
        variable-refresh-rate = true;
      }
    ] ++ map (rule: { layer-rule = rule; }) [
      {
        match._props.namespace = "^(launcher)$";
        background-effect = {
          blur = true;
          xray = false;
        };
        geometry-corner-radius = 24;
      }
      {
        match._props.namespace = "^noctalia-backdrop";
        place-within-backdrop = true;
      }
      {
        match._props.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|osd)$";
        background-effect.xray = false;
      }
      {
        match._props.namespace = "^noctalia-notifications";
        block-out-from = "screen-capture";
      }
      {
        match._props.namespace = "^noctalia-dock";
        geometry-corner-radius = 16;
      }
    ];
  };
}
