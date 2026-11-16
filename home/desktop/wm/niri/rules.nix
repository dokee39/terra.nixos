{ ... }:

{
  wayland.windowManager.niri.settings = {
    _children = map (rule: { window-rule = rule; }) [
      # ── force tile ──
      {
        match._props.app-id = "^Aseprite$";
        open-floating = false;
      }

      # ── force float ──
      {
        match._props.app-id = "^(qq|QQ|wechat|org\\.telegram\\.desktop|sxiv|imv|org\\.gnome\\.Loupe|rustdesk|tlpui|lxappearance|qt6ct|org\\.fcitx\\.fcitx5-config-qt|org\\.gnome\\.Nautilus)$";
        open-floating = true;
      }

      # ── rmpc ──
      {
        match._props.app-id = "^rmpc$";
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── clipse ──
      {
        match._props.app-id = "^clipse$";
        open-floating = true;
        default-column-width = { fixed = 622; };
        default-window-height = { fixed = 652; };
      }

      # ── GTK portal dialogs (independent of title and language) ──
      {
        match._props.app-id = "^xdg-desktop-portal-gtk$";
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Chrome print dialog ──
      {
        match._props = { app-id = "^google-chrome$"; title = "Print"; };
        open-floating = true;
      }

      # ── Picture-in-Picture ──
      {
        match._props.title = "Picture-in-picture";
        open-floating = true;
        opacity = 1.0;
      }

      # ── rog-control-center ──
      {
        match._props.app-id = "^rog-control-center$";
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Steam ──
      {
        match._props = {
          app-id = "^steam$";
          title = "^Steam Big Picture Mode$";
        };
        open-fullscreen = true;
      }

      # ── Steam games ──
      {
        match._props.app-id = "^steam_(proton|app_[0-9]+)$";
        open-fullscreen = true;
        opacity = 1.0;
        variable-refresh-rate = true;
      }
    ] ++ map (rule: { layer-rule = rule; }) [
      {
        match._props.namespace = "^(launcher)$";
        background-effect = {
          blur = true;
          xray = false;
        };
      }
      {
        match._props.namespace = "^noctalia-backdrop";
        place-within-backdrop = true;
      }
      {
        match._props.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";
        background-effect.xray = false;
      }
      {
        match._props.namespace = "^noctalia-notification$";
        block-out-from = "screen-capture";
      }
    ];
  };
}
