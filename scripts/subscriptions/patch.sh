#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

yq eval --from-file "$script_dir/common.yq" "$2" |
  yq eval --from-file "$script_dir/$1.yq" -
