{ lib, pkgs, sources, ... }:

let
  launcher = pkgs.writeShellApplication {
    name = "qq";
    runtimeInputs = with pkgs; [ coreutils findutils inotify-tools flatpak ];
    # HACK: prevent QQ from auto-updating itself at runtime.
    text = ''
      dir="$HOME/.var/app/com.qq.QQ/config/QQ/versions"
      mkdir -p "$dir"

      cleanup_once() {
        find "$dir" -maxdepth 1 -type f -name '*.zip.zip' -delete
      }

      cleanup_once

      exec {updates_fd}< <(exec inotifywait --monitor --quiet \
        --event create --event moved_to --event close_write \
        --format '%f' "$dir")
      monitor_pid=$!

      watch_updates() {
        while IFS= read -r -u "$updates_fd" event; do
          case "$event" in
            *.zip.zip) cleanup_once ;;
          esac
        done
      }

      watch_updates &
      watcher_pid=$!
      exec {updates_fd}<&-

      # Either process may already have exited when QQ closes.
      trap '
        kill "$watcher_pid" "$monitor_pid" 2>/dev/null || true
        wait "$watcher_pid" "$monitor_pid" 2>/dev/null || true
      ' EXIT

      flatpak run --user com.qq.QQ "$@" &
      qq_pid=$!
      trap 'kill -INT "$qq_pid" 2>/dev/null || true; exit 130' INT
      trap 'kill -TERM "$qq_pid" 2>/dev/null || true; exit 143' TERM

      rc=0
      wait "$qq_pid" || rc=$?
      exit "$rc"
    '';
  };
in
{
  home.packages = [ launcher ];

  services.flatpak = {
    packages = [ { inherit (sources.qq) appId origin commit; } ];
    overrides."com.qq.QQ".Context.filesystems = [ "xdg-pictures" ];
  };

  xdg.desktopEntries."com.qq.QQ" = {
    name = "QQ";
    exec = "${lib.getExe launcher} %U";
    icon = "com.qq.QQ";
    categories = [ "Network" "InstantMessaging" ];
    settings = {
      StartupWMClass = "QQ";
      X-Flatpak = "com.qq.QQ";
    };
  };
}
