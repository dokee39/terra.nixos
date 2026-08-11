{ config, lib, pkgs, ... }:

let
  cfg = config.terra.mihomo;
in
{
  age.secrets.mihomo-subscription-url.file = ../../secrets/mihomo-subscription-url.age;

  services.mihomo.webui = pkgs.metacubexd;

  systemd.timers.mihomo-subscription-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "45s";
      OnUnitActiveSec = "1w";
      RandomizedDelaySec = "2m";
      Persistent = true;
      Unit = "mihomo-subscription-update.service";
    };
  };

  systemd.services.mihomo-subscription-update = {
    description = "Refresh mihomo config from subscription URL";

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = with pkgs; [
      config.services.mihomo.package
      curl
      coreutils
      findutils
      gnugrep
      systemd
      yq-go
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      UMask = "0077";
      TimeoutStartSec = "2min";
    };

    script = let
      subUrlFile = config.age.secrets.mihomo-subscription-url.path;
      patchExpr = builtins.replaceStrings ["__TUN_DEVICE__"] [cfg.tunDevice] (builtins.readFile ./mihomo-patch.yq);
    in ''
      set -euo pipefail

      mkdir -p /var/lib/private/mihomo

      err() {
        echo "mihomo-subscription-update: $1" >&2
        exit 1
      }

      url="$(tr -d '\r\n' < ${lib.escapeShellArg subUrlFile})" || err "failed to read subscription URL"
      [ -n "$url" ] || err "subscription URL is empty"

      cfg="/var/lib/private/mihomo/config.yaml"
      cfg_dir="$(dirname "$cfg")"
      tmp="$(mktemp "$cfg_dir/.config.yaml.tmp.XXXXXX")"
      trap 'rm -f "$tmp"' EXIT

      curl --http1.1 \
        --fail --location --silent --show-error \
        --connect-timeout 10 \
        --max-time 60 \
        --retry 5 \
        --retry-delay 10 \
        "$url" \
        -o "$tmp" || err "failed to download subscription config"

      [ -s "$tmp" ] || err "downloaded subscription config is empty"

      yq -i '${patchExpr}' "$tmp" || err "failed to patch subscription config"
      mihomo -t -d "$cfg_dir" -f "$tmp" || err "downloaded config failed validation"

      chmod 600 "$tmp" || err "failed to set config permissions"
      chown root:root "$tmp" || err "failed to set config ownership"

      mv -f "$tmp" "$cfg" || err "failed to replace config"

      systemctl restart mihomo.service
    '';
  };
}
