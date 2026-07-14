{ config, pkgs, ... }:

let
  downloads = "${config.home.homeDirectory}/Downloads";

  sorter = pkgs.writeShellScript "download-sorter" ''
    set -eu

    mkdir=${pkgs.coreutils}/bin/mkdir
    mv=${pkgs.coreutils}/bin/mv
    file=${pkgs.file}/bin/file
    inotifywait=${pkgs.inotify-tools}/bin/inotifywait

    $inotifywait -m \
      -e close_write,moved_to \
      --format '%f%0' \
      --no-newline \
      ${downloads} |
    while IFS= read -r -d $'\0' f; do
      src=${downloads}/"$f"

      [ -f "$src" ] || continue
      [ ! -L "$src" ] || continue

      case "$f" in
        .*|*.crdownload|*.part|*.partial|*.download|*.tmp|*.temp|*.opdownload|*.aria2|*.!qB|.~lock.*|*~)
          continue
          ;;
        *)
          mime="$($file --mime-type -b -- "$src" 2>/dev/null || true)"
          ;;
      esac

      case "$mime" in
        application/x-bittorrent)
          dst=${downloads}/torrents
          ;;
        image/*)
          dst=${downloads}/images
          ;;
        video/*)
          dst=${downloads}/video
          ;;
        audio/*)
          dst=${downloads}/audio
          ;;
        text/*|application/json|application/*+json|application/xml|application/*+xml)
          dst=${downloads}/text
          ;;
        application/pdf|application/epub+zip|application/rtf|application/msword|application/vnd.ms-*|application/vnd.openxmlformats-officedocument.*|application/vnd.oasis.opendocument.*)
          dst=${downloads}/docs
          ;;
        application/zip|application/gzip|application/x-bzip2|application/x-xz|application/x-tar|application/x-7z-compressed|application/vnd.rar|application/zstd)
          dst=${downloads}/archives
          ;;
        *)
          continue
          ;;
      esac

      [ -e "$src" ] || continue
      [ -d "$dst" ] || $mkdir -p -- "$dst"
      $mv -- "$src" "$dst"/
    done
  '';
in
{
  systemd.user.services.download-sorter = {
    Unit.Description = "Sort Downloads by MIME type";

    Service = {
      ExecStart = "${sorter}";
      Restart = "always";
      RestartSec = 2;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
