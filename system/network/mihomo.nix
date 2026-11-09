{ config, lib, pkgs, ... }:

{
  services.mihomo.webui = pkgs.metacubexd;

  systemd.services.mihomo.serviceConfig = {
    RuntimeDirectory = "mihomo";
    RuntimeDirectoryMode = "0700";
  };

  systemd.timers.mihomo-subscription-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "45s";
      OnCalendar = "*-*-* 01,13:19:00 UTC";
      RandomizedDelaySec = "2m";
    };
  };

  systemd.services.mihomo-subscription-update = {
    description = "Refresh mihomo config from encrypted subscription";

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    path = with pkgs; [
      age
      curl
      coreutils
      diffutils
      jq
    ];

    serviceConfig = {
      Type = "oneshot";
      UMask = "0077";
      TimeoutStartSec = "10min";
    };

    script = ''
      set -euo pipefail

      cfg=${lib.escapeShellArg config.services.mihomo.configFile}
      cfg_dir="$(dirname "$cfg")"
      mkdir -p "$cfg_dir"
      tmp="$(mktemp -d "$cfg_dir/.subscription.XXXXXX")"
      trap 'rm -rf "$tmp"' EXIT

      curl --http1.1 \
        --fail --location --silent --show-error \
        --connect-timeout 10 \
        --max-time 60 \
        --retry 5 \
        --retry-delay 10 \
        "https://raw.githubusercontent.com/dokee39/terra.nixos/subscriptions/nixos.yaml.age" \
        -o "$tmp/config.yaml.age"

      age --decrypt --identity /etc/ssh/ssh_host_ed25519_key \
        --output "$tmp/config.yaml" "$tmp/config.yaml.age"

      if cmp -s "$tmp/config.yaml" "$cfg"; then
        exit 0
      fi

      jq -Rs '{payload: .}' "$tmp/config.yaml" |
        curl --unix-socket /run/mihomo/controller.sock \
          --noproxy '*' --fail --silent --show-error \
          --request PUT --header 'Content-Type: application/json' \
          --data-binary @- http://localhost/configs > /dev/null

      mv -f "$tmp/config.yaml" "$cfg"
    '';
  };
}
