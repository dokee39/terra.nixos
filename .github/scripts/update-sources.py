#!/usr/bin/env python3
"""Check external sources listed in sources.json for new releases.

For each entry:
  - type "binary": check GitHub releases for newer version,
    prefetch hash, update entry in place.
  - type "source": check GitHub releases for newer tag,
    prefetch source tarball hash via nix-prefetch-url.
  - type "flake": check GitHub releases for newer tag,
    resolve tag to commit SHA, prefetch source tarball hash.

Writes updated sources.json if changes found.
Prints change summary to stdout.
Exits 0 on clean completion; per-source API/prefetch errors printed to stderr and skipped.
"""

import json
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
SOURCES_FILE = REPO_ROOT / "sources.json"


def _gh_api(endpoint: str) -> dict:
    r = subprocess.run(
        ["gh", "api", endpoint, "--jq", "."],
        capture_output=True, text=True, check=True,
    )
    return json.loads(r.stdout)


def _prefetch(url: str) -> str:
    r = subprocess.run(
        ["nix", "store", "prefetch-file", "--json", url],
        capture_output=True, text=True, check=True,
    )
    return json.loads(r.stdout)["hash"]


def _prefetch_source_tarball(url: str) -> str:
    """Prefetch source tarball and return SRI hash matching builtins.fetchTree narHash.

    Uses nix-prefetch-url --unpack to compute hash of unpacked tree content
    rather than the compressed archive, so the result works for both
    pkgs.fetchFromGitHub (source) and builtins.fetchTree (flake).
    """
    r = subprocess.run(
        ["nix-prefetch-url", "--unpack", url],
        capture_output=True, text=True, check=True,
    )
    base32_hash = r.stdout.strip()
    r2 = subprocess.run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32_hash],
        capture_output=True, text=True, check=True,
    )
    return r2.stdout.strip()


def _check_new_version(owner: str, repo: str, current_version: str) -> str | None:
    """Check GitHub releases for a newer version.

    Returns the new tag_name if a newer version exists, None otherwise.
    Prints skip messages to stderr on errors.
    """
    if not owner or not repo:
        print(f"  [skip] missing owner/repo", file=sys.stderr)
        return None

    try:
        release = _gh_api(f"repos/{owner}/{repo}/releases/latest")
    except subprocess.CalledProcessError as e:
        print(f"  [skip] GitHub API failed: {e}", file=sys.stderr)
        return None

    latest_tag = release.get("tag_name", "")
    if not latest_tag:
        print(f"  [skip] no tag_name in latest release", file=sys.stderr)
        return None

    return latest_tag if latest_tag != current_version else None


def _update_source(entry: dict) -> bool:
    """Update source-type entry: tag used directly as rev."""
    latest_tag = _check_new_version(
        entry.get("owner", ""), entry.get("repo", ""), entry["version"]
    )
    if latest_tag is None:
        return False

    tarball_url = f"https://github.com/{entry['owner']}/{entry['repo']}/archive/{latest_tag}.tar.gz"
    try:
        new_hash = _prefetch_source_tarball(tarball_url)
    except subprocess.CalledProcessError as e:
        print(f"  [skip] prefetch failed: {e}", file=sys.stderr)
        return False

    entry["version"] = latest_tag
    entry["rev"] = latest_tag
    entry["hash"] = new_hash
    return True


def _update_flake(entry: dict) -> bool:
    """Update flake-type entry: tag resolved to commit SHA for rev."""
    latest_tag = _check_new_version(
        entry.get("owner", ""), entry.get("repo", ""), entry["version"]
    )
    if latest_tag is None:
        return False

    try:
        ref = _gh_api(f"repos/{entry['owner']}/{entry['repo']}/commits/{latest_tag}")
        commit_sha = ref["sha"]
    except (subprocess.CalledProcessError, KeyError) as e:
        print(f"  [skip] tag resolve failed: {e}", file=sys.stderr)
        return False

    tarball_url = f"https://github.com/{entry['owner']}/{entry['repo']}/archive/{commit_sha}.tar.gz"
    try:
        new_hash = _prefetch_source_tarball(tarball_url)
    except subprocess.CalledProcessError as e:
        print(f"  [skip] prefetch failed: {e}", file=sys.stderr)
        return False

    entry["version"] = latest_tag
    entry["rev"] = commit_sha
    entry["hash"] = new_hash
    return True


def _update_binary(entry: dict) -> bool:
    """Update binary-type entry: parses GitHub release assets by URL."""
    parsed = urlparse(entry["url"])
    if "github.com" not in parsed.netloc:
        print(f"  [skip] not a GitHub URL: {entry['url']}", file=sys.stderr)
        return False
    path_parts = parsed.path.strip("/").split("/")
    if len(path_parts) < 2:
        print(f"  [skip] cannot parse owner/repo from URL: {entry['url']}", file=sys.stderr)
        return False
    owner, repo_name = path_parts[0], path_parts[1]
    asset_name = entry["url"].rstrip("/").rsplit("/", 1)[-1]
    if not asset_name:
        print(f"  [skip] cannot parse asset name from URL: {entry['url']}", file=sys.stderr)
        return False

    latest_tag = _check_new_version(owner, repo_name, entry["version"])
    if latest_tag is None:
        return False

    # Refetch to get full release data for asset iteration
    try:
        release = _gh_api(f"repos/{owner}/{repo_name}/releases/latest")
    except subprocess.CalledProcessError as e:
        print(f"  [skip] GitHub API failed: {e}", file=sys.stderr)
        return False

    new_url = None
    for asset in release.get("assets", []):
        if asset.get("name") == asset_name:
            new_url = asset.get("browser_download_url")
            break

    if not new_url:
        print(f"  [skip] asset '{asset_name}' not found in release {latest_tag}", file=sys.stderr)
        return False

    try:
        new_hash = _prefetch(new_url)
    except subprocess.CalledProcessError as e:
        print(f"  [skip] prefetch failed: {e}", file=sys.stderr)
        return False

    entry["version"] = latest_tag
    entry["url"] = new_url
    entry["hash"] = new_hash
    return True


def main() -> None:
    sources = json.loads(SOURCES_FILE.read_text())
    changes = []

    for name, entry in sources.items():
        entry_type = entry.get("type", "")
        old_version = entry.get("version", "")
        print(f"Checking {name} ({old_version})...", file=sys.stderr)

        if entry_type == "binary":
            if _update_binary(entry):
                changes.append((name, old_version, entry["version"]))
        elif entry_type == "source":
            if _update_source(entry):
                changes.append((name, old_version, entry["version"]))
        elif entry_type == "flake":
            if _update_flake(entry):
                changes.append((name, old_version, entry["version"]))
        else:
            print(f"  [skip] unknown type: {entry_type}", file=sys.stderr)

    if changes:
        SOURCES_FILE.write_text(json.dumps(sources, indent=2) + "\n")
        print("### Sources Updated ###")
        for name, old, new in changes:
            print(f"{name}: {old} \u2192 {new}")
        print(f"Updated {len(changes)} source(s).")
    else:
        print("No sources updates found.", file=sys.stderr)


if __name__ == "__main__":
    main()
