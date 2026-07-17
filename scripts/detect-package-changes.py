#!/usr/bin/env python3
"""Compare flake inputs and selected nixpkgs packages across two flake.lock revisions."""

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WATCH_FILE = ROOT / ".github" / "config" / "watch-packages.json"


def _git_show(ref: str, path: str) -> str | None:
    r = subprocess.run(
        ["git", "show", f"{ref}:{path}"],
        capture_output=True, text=True,
    )
    return r.stdout if r.returncode == 0 else None


def _parse_locks(content: str) -> dict[str, dict[str, str | int | None]]:
    data = json.loads(content)
    nodes: dict[str, dict] = {}
    for name, node in data.get("nodes", {}).items():
        locked = node.get("locked")
        if locked is None:
            continue
        entry = {
            "rev": locked.get("rev", ""),
            "narHash": locked.get("narHash", ""),
            "lastModified": locked.get("lastModified"),
            "type": locked.get("type"),
            "owner": locked.get("owner"),
            "repo": locked.get("repo"),
        }
        original = node.get("original", {})
        entry["original_url"] = original.get("url", "")
        nodes[name] = entry
    return nodes


def _input_url(entry: dict[str, str | int | None]) -> str:
    if entry.get("type") == "github" and entry.get("owner") and entry.get("repo"):
        return f"https://github.com/{entry['owner']}/{entry['repo']}"
    url = entry.get("original_url", "")
    if url.startswith("github:"):
        parts = url[7:].split("/")
        if len(parts) >= 2:
            return f"https://github.com/{parts[0]}/{parts[1]}"
    return url


def _short_label(val: str) -> str:
    """Short display label. Strip narHash alg prefix before truncation."""
    if val.startswith("sha256-") or val.startswith("sha512-"):
        val = val[7:]
    return val[:7]


def _fmt_date(ts: int | None) -> str:
    if ts:
        dt = datetime.fromtimestamp(ts, tz=timezone.utc)
        return dt.strftime("%Y-%m-%d")
    return ""


_EVAL_ERROR = "(error)"


def _nix_attr_version(attr: str, rev: str) -> str | None:
    for attempt in range(2):
        try:
            r = subprocess.run(
                [
                    "nix", "eval", "--json",
                    f"github:NixOS/nixpkgs/{rev}#{attr}.version",
                ],
                capture_output=True, text=True, timeout=60,
            )
            if r.returncode == 0:
                out = r.stdout.strip()
                if out:
                    v = json.loads(out)
                    if isinstance(v, str) and v:
                        return v
                return None
        except (subprocess.TimeoutExpired, json.JSONDecodeError):
            pass
    return _EVAL_ERROR


def _fmt_ver(v: str | None) -> str:
    if v is None:
        return "(missing)"
    if v == _EVAL_ERROR:
        return "(error)"
    return v


def _repo_owner() -> str:
    try:
        url = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
        m = re.search(r"github\.com[:/]([^/]+)/", url)
        return m.group(1) if m else ""
    except (subprocess.CalledProcessError, OSError):
        return ""


def _parse_sources(content: str) -> dict[str, dict[str, str]]:
    data = json.loads(content)
    entries: dict[str, dict] = {}
    for name, entry in data.items():
        entries[name] = {
            "version": entry.get("version", ""),
        }
    return entries


def main() -> None:
    args = _parse_args()

    if args.diff:
        old_ref, new_ref = args.diff
    else:
        r = subprocess.run(
            ["git", "rev-parse", "HEAD~1"],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            print("Only one commit in history. Skipping diff.", file=sys.stderr)
            sys.exit(0)
        old_ref, new_ref = "HEAD~1", "HEAD"

    old_content = _git_show(old_ref, "flake.lock")
    new_content = _git_show(new_ref, "flake.lock")
    if old_content is None or new_content is None:
        print(f"Could not read flake.lock from {old_ref} or {new_ref}.", file=sys.stderr)
        sys.exit(1)

    # Resolve refs to commit hashes for header display
    r_old = subprocess.run(["git", "rev-parse", old_ref], capture_output=True, text=True)
    r_new = subprocess.run(["git", "rev-parse", new_ref], capture_output=True, text=True)
    old_commit = r_old.stdout.strip() if r_old.returncode == 0 else old_ref
    new_commit = r_new.stdout.strip() if r_new.returncode == 0 else new_ref

    old_lock = _parse_locks(old_content)
    new_lock = _parse_locks(new_content)

    # Part A: flake input diff
    input_changes: list[dict] = []
    for name in sorted(set(old_lock) | set(new_lock)):
        old = old_lock.get(name)
        new = new_lock.get(name)
        if old is None:
            input_changes.append({
                "name": name, "old": "(added)", "new": "",
                "url": "",
            })
        elif new is None:
            input_changes.append({
                "name": name, "old": "(removed)", "new": "",
                "url": _input_url(old),
            })
        else:
            old_rev = old.get("rev", "")
            new_rev = new.get("rev", "")
            if not old_rev and not new_rev:
                old_rev = old.get("original_url", "")
                new_rev = new.get("original_url", "")
                if old_rev and old_rev == new_rev and old.get("type") in ("tarball", "file"):
                    # Same URL (e.g. 'latest' tarball) — compare narHash instead
                    old_rev = old.get("narHash", "")
                    new_rev = new.get("narHash", "")
                elif not old_rev and not new_rev:
                    old_rev = json.dumps(old, sort_keys=True)
                    new_rev = json.dumps(new, sort_keys=True)
            if old_rev and new_rev and old_rev != new_rev:
                old_ts = _fmt_date(old.get("lastModified"))
                new_ts = _fmt_date(new.get("lastModified"))
                old_label = _short_label(old_rev)
                new_label = _short_label(new_rev)
                if old_ts:
                    old_label += f" ({old_ts})"
                if new_ts:
                    new_label += f" ({new_ts})"
                input_changes.append({
                    "name": name,
                    "old": old_label,
                    "new": new_label,
                    "url": _input_url(new),
                })

    # Part B: nixpkgs attr version diff
    old_nixpkgs = old_lock.get("nixpkgs", {}).get("rev", "")
    new_nixpkgs = new_lock.get("nixpkgs", {}).get("rev", "")
    if not old_nixpkgs or not new_nixpkgs:
        print("Error: nixpkgs rev missing from flake.lock", file=sys.stderr)
        sys.exit(1)

    attrs = json.loads(WATCH_FILE.read_text())

    pkg_changes: list[dict] = []
    if old_nixpkgs != new_nixpkgs:
        for attr in attrs:
            old_ver = _nix_attr_version(attr, old_nixpkgs)
            new_ver = _nix_attr_version(attr, new_nixpkgs)
            if old_ver != new_ver:
                pkg_changes.append({
                    "name": attr,
                    "old": _fmt_ver(old_ver),
                    "new": _fmt_ver(new_ver),
                })

    # Part C: sources.json diff — always from the same refs as flake.lock
    sources_changes: list[dict] = []
    old_src_raw = _git_show(old_ref, "sources.json")
    new_src_raw = _git_show(new_ref, "sources.json")
    old_src = _parse_sources(old_src_raw) if old_src_raw else {}
    new_src = _parse_sources(new_src_raw) if new_src_raw else {}

    for name in sorted(set(old_src) | set(new_src)):
        old = old_src.get(name, {}).get("version", "")
        new = new_src.get(name, {}).get("version", "")
        if old and new and old != new:
            sources_changes.append({"name": name, "old": old, "new": new})
        elif old and not new:
            sources_changes.append({"name": name, "old": old, "new": "(removed)"})
        elif not old and new:
            sources_changes.append({"name": name, "old": "(added)", "new": new})

    if not input_changes and not pkg_changes and not sources_changes:
        print("No changes detected.", file=sys.stderr)
        return

    # Build body
    body = ""
    if not args.plain:
        owner = _repo_owner()
        body += "# Update Report"
        if old_commit and new_commit:
            body += f": {old_commit[:7]}...{new_commit[:7]}"
        body += "\n\n"
        if owner:
            body += f"@{owner}\n\n"

    if input_changes:
        body += "## Flake Input Changes\n\n"
        if args.plain:
            for c in input_changes:
                name = c['name']
                if c['old'] == "(added)":
                    body += f"{name}  (added)\n"
                elif c['old'] == "(removed)":
                    body += f"{name}  (removed)\n"
                else:
                    body += f"{name}  {c['old']} \u2192 {c['new']}\n"
        else:
            body += "| Input | Old | New |\n|-------|-----|-----|\n"
            for c in input_changes:
                url = c.get("url", "")
                name = f"[{c['name']}]({url})" if url else c['name']
                body += f"| {name} | {c['old']} | {c['new']} |\n"
        body += "\n"

    if sources_changes:
        body += "## Sources Updated\n\n"
        if args.plain:
            for c in sources_changes:
                body += f"{c['name']}  {c['old']} \u2192 {c['new']}\n"
        else:
            body += "| Source | Old | New |\n|--------|-----|-----|\n"
            for c in sources_changes:
                body += f"| {c['name']} | {c['old']} | {c['new']} |\n"
        body += "\n"

    if pkg_changes:
        body += "## Package Version Changes\n\n"
        if args.plain:
            for c in pkg_changes:
                name = c['name']
                body += f"{name}  {c['old']} \u2192 {c['new']}\n"
        else:
            body += "| Package | Old | New |\n|---------|-----|-----|\n"
            for c in pkg_changes:
                url = f"https://search.nixos.org/packages?channel=unstable&query={c['name']}"
                name = f"[{c['name']}]({url})"
                body += f"| {name} | {c['old']} | {c['new']} |\n"
        body += "\n"

    print(body, end="")


def _parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--diff", nargs=2, metavar=("OLD_REF", "NEW_REF"),
                   help="Compare two git refs (commit, branch, etc.) instead of HEAD~1 vs HEAD")
    p.add_argument("--plain", action="store_true",
                   help="Arrow format, no links, no title (for commit messages)")
    return p.parse_args()


if __name__ == "__main__":
    main()
