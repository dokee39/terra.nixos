#!/usr/bin/env bash
set -euo pipefail
umask 077

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p -- "$1"
output_dir="$(cd -- "$1" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT

err() {
  printf 'subscriptions: %s\n' "$1" >&2
  exit 1
}

cd "$script_dir/../.."

nix eval --raw --file ./secrets/keys.nix hosts \
  --apply 'keys: builtins.concatStringsSep "\n" keys + "\n"' \
  > "$work_dir/nixos.pub"
cp "$script_dir/android.pub" "$work_dir/android.pub"

# Download and parser diagnostics can contain subscription credentials.
curl --http1.1 \
  --fail --location --silent --show-error \
  --connect-timeout 10 \
  --max-time 60 \
  --retry 5 \
  --retry-delay 10 \
  "$MIHOMO_SUBSCRIPTION_URL" \
  -o "$work_dir/provider.yaml" \
  2> /dev/null || err "failed to download provider configuration"

yq eval --exit-status \
  '(tag == "!!map") and ((.proxies | tag) == "!!seq") and ((.proxies | length) > 0)' \
  "$work_dir/provider.yaml" > /dev/null 2>&1 \
  || err "provider configuration must contain a non-empty proxies list"

for device in android nixos; do
  bash "$script_dir/patch.sh" "$device" "$work_dir/provider.yaml" \
    > "$work_dir/$device.yaml" 2> /dev/null \
    || err "failed to apply $device patches"

  mkdir "$work_dir/$device"
  mihomo -t -d "$work_dir/$device" -f "$work_dir/$device.yaml" \
    > /dev/null 2>&1 || err "$device configuration failed Mihomo validation"

  age --encrypt --armor --recipients-file "$work_dir/$device.pub" \
    --output "$work_dir/$device.yaml.age" "$work_dir/$device.yaml"
done

install -m 0600 "$work_dir/android.yaml.age" "$work_dir/nixos.yaml.age" "$output_dir/"
