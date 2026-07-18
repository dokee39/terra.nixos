{
  lib,
  pkgs,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  writeShellApplication,
  inotify-tools,
  coreutils,
  findutils,
  desktopContext ? {},
  ...
}:

let
  appId = "com.qq.QQ";

  wrapped = mkNixPak {
    config = { ... }: {
      _module.args = {
        inherit desktopContext;
      };

      app = {
        package = pkgs.qq.overrideAttrs (old: {
          runtimeDependencies =
            (old.runtimeDependencies or [])
            ++ map lib.getLib [
              pkgs.libpulseaudio
              pkgs.alsa-lib
            ];
        });
        binPath = "bin/qq";
      };

      flatpak.appId = appId;

      imports = [
        ./modules/sandbox-base.nix
        ./modules/desktop-integration.nix
        ./modules/capabilities.nix
      ];

      sandbox.capabilities = {
        network.enable = true;
        tray.enable = true;
        audio.enable = true;
        camera.enable = true;
        downloads = "rw";
        pictures = "rw";
      };
    };
  };

  launcher = writeShellApplication {
    name = "qq";

    runtimeInputs = [
      inotify-tools
      coreutils
      findutils
    ];

    text = ''
      set -eu

      dir="$HOME/.var/app/${appId}/config/QQ/versions"
      mkdir -p "$dir"

      cleanup_once() {
        find "$dir" -maxdepth 1 -type f -name '*.zip.zip' -delete 2>/dev/null || true
      }

      watch_updates() {
        while inotifywait -q -e create -e moved_to -e close_write "$dir" >/dev/null 2>&1; do
          find "$dir" -maxdepth 1 -type f -name '*.zip.zip' -delete 2>/dev/null || true
        done
      }

      cleanup_once
      watch_updates &
      watcher_pid=$!

      stop_watcher() {
        kill "$watcher_pid" 2>/dev/null || true
        wait "$watcher_pid" 2>/dev/null || true
      }

      trap stop_watcher EXIT INT TERM

      "${lib.getExe wrapped.config.script}" "$@" &
      qq_pid=$!
      wait "$qq_pid"
      rc=$?

      stop_watcher
      exit "$rc"
      '';
  };

  exePath = lib.getExe launcher;
in
  buildEnv {
    inherit (wrapped.config.script) name meta passthru;

    paths = [
      launcher

      (makeDesktopItem {
        name = appId;
        desktopName = "QQ";
        genericName = "QQ Boxed";
        comment = "Tencent QQ sandboxed with nixpak";
        exec = "${exePath} %U";
        terminal = false;
        icon = "${pkgs.qq}/share/icons/hicolor/512x512/apps/qq.png";
        startupNotify = true;
        startupWMClass = "QQ";
        type = "Application";
        categories = [ "InstantMessaging" "Network" ];
        extraConfig = {
          X-Flatpak = appId;
        };
      })
    ];
  }
