#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../tests/test-flake"

nix flake lock --override-input nixpkgs "github:NixOS/nixpkgs/$1"
OLD=$(nix build '.#nixosConfigurations.ci-diff.config.system.build.toplevel' --no-link --print-out-paths)

nix flake lock --override-input nixpkgs "github:NixOS/nixpkgs/$2"
NEW=$(nix build '.#nixosConfigurations.ci-diff.config.system.build.toplevel' --no-link --print-out-paths)

DIX_OUT=$(nix run nixpkgs#dix -- --color always "$OLD" "$NEW")
echo "$DIX_OUT"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  echo "## Package Changes" >> "$GITHUB_STEP_SUMMARY"
  echo "$DIX_OUT" | nix run nixpkgs#aha -- --black --no-header >> "$GITHUB_STEP_SUMMARY"
fi
