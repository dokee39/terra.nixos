{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.terra.mihomo;
  mihomoConfigPath = "/var/lib/mihomo/config.yaml";
  subUrlFile = config.age.secrets.mihomo-subscription-url.path;
  mmdbSrc = "${inputs.mmdb}/Country.mmdb";
in
{
  options.terra.mihomo = {
    subscriptionUrl_secretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a secret file containing the Mihomo subscription URL.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7890;
    };
    tunDevice = lib.mkOption {
      type = lib.types.str;
      default = "tun0";
    };
  };

  config = {
    age.secrets.mihomo-subscription-url.file = cfg.subscriptionUrl_secretFile;

    services.mihomo = {
      enable = true;
      tunMode = true;
      processesInfo = true;
      webui = pkgs.metacubexd;
      configFile = mihomoConfigPath;
    };

    networking.firewall.trustedInterfaces = [ config.terra.mihomo.tunDevice ];

    system.activationScripts.mihomo-mmdb = {
      text = ''
        install -d -m 0755 /var/lib/private/mihomo
        install -m 0644 ${lib.escapeShellArg mmdbSrc} /var/lib/private/mihomo/country.mmdb
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/mihomo 0700 root root -"
    ];

    systemd.services.mihomo-subscription-update = {
      description = "Refresh mihomo config from subscription URL";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      path = with pkgs; [
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

      script = ''
        set -euo pipefail

        err() {
          echo "mihomo-subscription-update: $1" >&2
          exit 1
        }

        url="$(tr -d '\r\n' < ${lib.escapeShellArg subUrlFile})" || err "failed to read subscription URL"
        [ -n "$url" ] || err "subscription URL is empty"

        cfg=${lib.escapeShellArg mihomoConfigPath}
        cfg_dir="$(dirname "$cfg")"
        tmp="$(mktemp "$cfg_dir/.config.yaml.tmp.XXXXXX")"
        trap 'rm -f "$tmp"' EXIT

        curl --fail --location --silent --show-error \
          --connect-timeout 10 \
          --max-time 60 \
          --retry 5 \
          --retry-delay 10 \
          "$url" \
          -o "$tmp" || err "failed to download subscription config"

        [ -s "$tmp" ] || err "downloaded subscription config is empty"

        yq -i '
          .port = ${toString cfg.port} |

          .tun.enable = true |
          .tun.device = "${cfg.tunDevice}" |
          .tun.stack = "mixed" |
          .tun."auto-route" = true |
          .tun."auto-redirect" = true |
          .tun."auto-detect-interface" = true |

          .["proxy-groups"] |= (
            (. // [])
            | map(
                select(
                  .name != "⚡ 自动切换" and
                  .name != "⚡ 自动切换-日本" and
                  .name != "⚡ 自动切换-香港"
                )
              )
          ) |

          .["proxy-groups"] = (
            [
              {
                "name": "⚡ 自动切换-日本",
                "type": "url-test",
                "include-all-proxies": true,
                "filter": "日本",
                "exclude-filter": "免费",
                "url": "https://www.gstatic.com/generate_204",
                "expected-status": 204,
                "interval": 120,
                "tolerance": 100,
                "lazy": false,
                "timeout": 2000,
                "max-failed-times": 3
              },
              {
                "name": "⚡ 自动切换-香港",
                "type": "url-test",
                "include-all-proxies": true,
                "filter": "香港",
                "exclude-filter": "免费",
                "url": "https://www.gstatic.com/generate_204",
                "expected-status": 204,
                "interval": 120,
                "tolerance": 100,
                "lazy": false,
                "timeout": 2000,
                "max-failed-times": 3
              },
              {
                "name": "⚡ 自动切换",
                "type": "fallback",
                "proxies": [
                  "⚡ 自动切换-日本",
                  "⚡ 自动切换-香港"
                ],
                "url": "https://www.gstatic.com/generate_204",
                "expected-status": 204,
                "interval": 120,
                "lazy": false,
                "timeout": 2000,
                "max-failed-times": 3
              }
            ] + .["proxy-groups"]
          ) |

          with(.["proxy-groups"][] | select(.name == "🔰 选择节点");
            .type = "select" |
            .proxies = (
              [
                "⚡ 自动切换",
                "⚡ 自动切换-日本",
                "⚡ 自动切换-香港"
              ] +
              (
                (.proxies // [])
                | map(
                    select(
                      . != "⚡ 自动切换" and
                      . != "⚡ 自动切换-日本" and
                      . != "⚡ 自动切换-香港"
                    )
                  )
              )
            )
          ) |
          .rules = (
            ["PROCESS-NAME-WILDCARD,*transmission*,DIRECT"]
            + (.rules // [])
          )
        ' "$tmp" || err "failed to patch subscription config"

        chmod 600 "$tmp" || err "failed to set config permissions"
        chown root:root "$tmp" || err "failed to set config ownership"

        mv -f "$tmp" "$cfg" || err "failed to replace config"

        ${pkgs.systemd}/bin/systemctl try-restart mihomo.service || true
      '';
    };

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
  };
}
