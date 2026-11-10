#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

yq eval-all --yaml-fix-merge-anchor-to-spec \
  --from-file "$script_dir/common.yq" "$script_dir/base.yaml" "$2" |
  yq eval --yaml-fix-merge-anchor-to-spec --from-file "$script_dir/$1.yq" -
