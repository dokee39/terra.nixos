{ ... }:

{
  programs.niri.settings = {
    window-rules = [
      # ── VSCode opacity (overrides global) ──
      {
        matches = [ { title = "Visual Studio Code"; is-active = false; } ];
        opacity = 0.80;
      }
      {
        matches = [ { title = "Visual Studio Code"; is-active = true; } ];
        opacity = 0.88;
      }

      # ── Explicitly force tile (apps that might auto-float) ──
      {
        matches = [ { app-id = "^(steam|Aseprite)$"; } ];
        open-floating = false;
      }

      # ── Float: broad class list ──
      {
        matches = [ {
          app-id = "^(qq|QQ|wechat|org\\.telegram\\.desktop|sxiv|imv|org\\.gnome\\.Loupe|rustdesk|tlpui|lxappearance|qt6ct|org\\.fcitx\\.fcitx5-config-qt|org\\.gnome\\.Nautilus)$";
        } ];
        open-floating = true;
      }

      # ── kitty: pulsemixer / bluetui / impala / rmpc ──
      {
        matches = [ {
          app-id = "kitty";
          title = "^(pulsemixer|bluetui|impala|rmpc)$";
        } ];
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── kitty: btop ──
      {
        matches = [ { app-id = "kitty"; title = "^btop$"; } ];
        open-floating = true;
        default-column-width = { proportion = 0.85; };
        default-window-height = { proportion = 0.85; };
      }

      # ── clipse ──
      {
        matches = [ { app-id = "clipse"; } ];
        open-floating = true;
        default-column-width = { fixed = 622; };
        default-window-height = { fixed = 652; };
      }

      # ── WeChat: no decorations ──
      {
        matches = [ { app-id = "wechat"; } ];
        open-floating = true;
        opacity = 1.0;
        clip-to-geometry = true;
      }

      # ── Select / Open dialogs ──
      {
        matches = [ { title = "^(Select|Open)"; } ];
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Chrome print dialog ──
      {
        matches = [ { app-id = "google-chrome"; title = "Print"; } ];
        open-floating = true;
      }

      # ── Picture-in-Picture ──
      {
        matches = [ { title = "Picture-in-picture"; } ];
        open-floating = true;
        opacity = 1.0;
      }

      # ── qView / Seahorse ──
      {
        matches = [ {
          app-id = "(com\\.interversehq\\.qView|org\\.gnome\\.seahorse\\.Application)";
        } ];
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Electron location dialog ──
      {
        matches = [ { app-id = "electron"; title = "Location"; } ];
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── rog-control-center ──
      {
        matches = [ { app-id = "rog-control-center"; } ];
        open-floating = true;
        default-column-width = { proportion = 0.618; };
        default-window-height = { proportion = 0.618; };
      }

      # ── Steam games ──
      {
        matches = [ { app-id = "^steam_app_[0-9]+$"; } ];
        open-fullscreen = true;
        variable-refresh-rate = true;
      }
    ];
  };
}
