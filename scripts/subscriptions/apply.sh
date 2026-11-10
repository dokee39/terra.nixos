#!/usr/bin/env bash
set -euo pipefail
umask 077

cfg=/var/lib/private/mihomo/config.yaml
tmp="$(mktemp -d "$(dirname "$cfg")/.apply.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

age --decrypt --identity /etc/ssh/ssh_host_ed25519_key \
  --output "$tmp/config.yaml" "$1"

cp -p "$cfg" "$cfg.bak"
mv -f "$tmp/config.yaml" "$cfg"
systemctl restart mihomo.service
