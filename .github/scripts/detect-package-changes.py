#!/usr/bin/env python3
"""Compare pname-version pairs across two nixpkgs revisions via derivation show."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import date

from pathlib import Path
from typing import Any

import yaml

FLAKE = Path(__file__).resolve().parent.parent.parent / ".github" / "tests" / "test-flake"
PKG_MAP = FLAKE.parent.parent / "config" / "pkg-map.yaml"


def _nix(cmd: list[str], **kwargs: Any) -> str:
    r = subprocess.run(cmd, capture_output=True, text=True, check=True, **kwargs)
    if r.stderr:
        print(r.stderr.rstrip(), file=sys.stderr)
    return r.stdout.strip()


def _git_read_file(ref: str, path: str = "flake.lock") -> str | None:
    r = subprocess.run(["git", "cat-file", "-p", f"{ref}:{path}"], capture_output=True, text=True)
    if r.returncode == 0:
        return r.stdout
    r = subprocess.run(["git", "show", f"{ref}:{path}"], capture_output=True, text=True)
    if r.returncode == 0:
        return r.stdout
    return None


def _repo_owner() -> str:
    try:
        url = _nix(["git", "remote", "get-url", "origin"])
        m = re.search(r"github\.com[:/]([^/]+)/", url)
        return m.group(1) if m else ""
    except (subprocess.CalledProcessError, OSError):
        return ""


def _parse_flake_rev(content: str) -> str | None:
    try:
        data = json.loads(content)
        return data["nodes"]["nixpkgs"]["locked"]["rev"]
    except (json.JSONDecodeError, KeyError):
        return None


def show_closure() -> dict[str, str]:
    """Return {pname: version} via nix derivation show --recursive.

    Note: only packages with pname+version in derivation env (~1/3 of
    all recursive derivations). Others silently excluded.
    """
    raw = _nix(
        [
            "nix", "derivation", "show", "--recursive",
            ".#nixosConfigurations.ci-diff.config.system.build.toplevel",
        ],
        cwd=str(FLAKE),
    )
    data = json.loads(raw)
    drs = data if isinstance(data, dict) else {}
    drs = drs.get("derivations", drs)
    pkgs: dict[str, str] = {}
    for drv in drs.values():
        env = drv.get("env", {})
        pn = env.get("pname")
        ver = env.get("version")
        if pn and ver:
            pkgs[pn] = ver
    return pkgs


def diff_packages(
    old: dict[str, str], new: dict[str, str]
) -> list[dict[str, str]]:
    all_names = set(old) | set(new)
    changes = []
    for name in sorted(all_names):
        old_ver = old.get(name)
        new_ver = new.get(name)
        if old_ver is None:
            changes.append({
                "name": name, "status": "Added",
                "old_version": "", "new_version": new_ver or "",
            })
        elif new_ver is None:
            changes.append({
                "name": name, "status": "Removed",
                "old_version": old_ver or "", "new_version": "",
            })
        elif old_ver != new_ver:
            changes.append({
                "name": name, "status": "Changed",
                "old_version": old_ver, "new_version": new_ver,
            })
    return changes


def load_pkg_map(path: Path) -> dict[str, Any]:
    raw = yaml.safe_load(path.read_text())
    return raw or {}


def is_url(s: str) -> bool:
    return isinstance(s, str) and (
        s.startswith("http://") or s.startswith("https://")
    )


_GITHUB_RE = re.compile(r"https?://github\.com/")


def redirect_github(text: str) -> str:
    return _GITHUB_RE.sub("https://redirect.github.com/", text)


def eval_meta(attr: str, rev: str) -> tuple[str | None, str | None]:
    try:
        out = _nix(
            [
                "nix", "eval",
                f"github:NixOS/nixpkgs/{rev}#{attr}.meta",
                "--json",
            ]
        )
        meta = json.loads(out)
        if not isinstance(meta, dict):
            return None, None
        desc = meta.get("description") or None
        hp = meta.get("homepage")
        if isinstance(hp, list):
            hp = hp[0] if hp else None
        elif not hp:
            hp = None
        return desc, hp
    except subprocess.CalledProcessError:
        return None, None


def _eval_and_assign(
    attr: str, entry: dict, nixpkgs_rev: str, eval_errors: list
) -> None:
    """Eval nixpkgs attr meta, populate entry fields."""
    print(f"  eval {attr}...", file=sys.stderr)
    desc, hp = eval_meta(attr, nixpkgs_rev)
    if desc is None and hp is None:
        eval_errors.append({"attr": attr, "error": "nix eval failed"})
    entry["description"] = desc
    entry["homepage"] = hp


def _classify_entries(
    entries: list[dict], pkg_map: dict, nixpkgs_rev: str
) -> dict:
    """Classify diff entries into buckets, eval meta for mapped packages."""
    changes = []
    unmapped = []
    added = []
    removed = []
    skipped = []
    eval_errors = []
    stats: dict[str, int] = {"changed": 0, "removed": 0, "added": 0, "total": 0}

    for e in entries:
        status = e["status"]
        if status in ("Added", "Removed"):
            stats[status.lower()] += 1
            stats["total"] += 1
            (added if status == "Added" else removed).append(e)
            continue

        mapping = pkg_map.get(e["name"])
        if mapping is False:
            skipped.append(e)
            continue

        stats[status.lower()] += 1
        stats["total"] += 1

        if mapping is None:
            unmapped.append(e)
            continue

        entry: dict[str, Any] = {
            "name": e["name"],
            "status": status,
            "old_version": e["old_version"],
            "new_version": e["new_version"],
            "homepage": None,
            "description": None,
        }

        if is_url(mapping):
            entry["homepage"] = mapping
        elif mapping is True:
            _eval_and_assign(e["name"], entry, nixpkgs_rev, eval_errors)
        elif isinstance(mapping, str):
            _eval_and_assign(mapping, entry, nixpkgs_rev, eval_errors)

        changes.append(entry)

    return {
        "changes": changes,
        "added": added,
        "removed": removed,
        "skipped": skipped,
        "unmapped": unmapped,
        "eval_errors": eval_errors,
        "stats": stats,
    }


def format_issue(old_rev: str, new_rev: str, buckets: dict, owner: str = "") -> str:
    s = buckets["stats"]
    lines = [
        f"# Package Update Report: {old_rev[:7]} \u2192 {new_rev[:7]}",
        "",
    ]

    if s["total"]:
        if owner:
            lines.append(f"@{owner}")
            lines.append("")
        lines.append(f"{s['total']} packages: "
                     f"{s['changed']} changed, {s['removed']} removed, "
                     f"{s['added']} added")
        lines.append("")

    if buckets["changes"]:
        lines.append("## Changes")
        lines.append("")
        for c in buckets["changes"]:
            ver = f"{c['old_version']} \u2192 {c['new_version']}"
            lines.append(f"### {c['name']}")
            lines.append("")
            lines.append(f"**Status:** {c['status']} {ver}")
            if c.get("homepage"):
                lines.append(f"**Homepage:** {c['homepage']}")
            if c.get("description"):
                lines.append(f"**Description:** {c['description']}")
            if c.get("analysis"):
                lines.append("")
                lines.append(c["analysis"])
            lines.append("")

    if buckets["added"] or buckets["removed"] or buckets["skipped"]:
        lines.append("## Full Diff")
        lines.append("")

        if buckets["added"]:
            lines.append("### Added")
            lines.append("")
            lines.append("| package | version |")
            lines.append("|---------|---------|")
            for a in buckets["added"]:
                lines.append(f"| {a['name']} | {a['new_version']} |")
            lines.append("")

        if buckets["removed"]:
            lines.append("### Removed")
            lines.append("")
            lines.append("| package | version |")
            lines.append("|---------|---------|")
            for r in buckets["removed"]:
                lines.append(f"| {r['name']} | {r['old_version']} |")
            lines.append("")

        if buckets["skipped"]:
            lines.append("### Skipped (false in pkg-map)")
            lines.append("")
            lines.append("| package | old \u2192 new |")
            lines.append("|---------|-------------|")
            for s in buckets["skipped"]:
                lines.append(f"| {s['name']} | {s['old_version']} \u2192 {s['new_version']} |")
            lines.append("")

    if buckets["unmapped"] or buckets["eval_errors"]:
        lines.append("## Errors")
        lines.append("")

        if buckets["unmapped"]:
            lines.append("### Unmapped")
            lines.append("")
            lines.append("| name | status |")
            lines.append("|------|--------|")
            for u in buckets["unmapped"]:
                lines.append(f"| {u['name']} | {u['status']} |")
            lines.append("")
            lines.append(
                "Add entries to `.github/config/pkg-map.yaml` "
                "to enable analysis."
            )
            lines.append("")

        if buckets["eval_errors"]:
            lines.append("### Eval Errors")
            lines.append("")
            lines.append("| attr | error |")
            lines.append("|------|-------|")
            for e in buckets["eval_errors"]:
                lines.append(f"| {e['attr']} | {e['error']} |")
            lines.append("")

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--output", type=Path, help="write issue body to file")
    args = parser.parse_args()

    root_dir = FLAKE.parent.parent.parent
    root_lock = root_dir / "flake.lock"
    test_lock = FLAKE / "flake.lock"
    locks = [root_lock, test_lock]

    commit_a = _nix(["git", "rev-parse", "HEAD~1"])
    commit_b = _nix(["git", "rev-parse", "HEAD"])

    saved = [p.read_text() for p in locks]

    try:
        for p in locks:
            rel = p.relative_to(root_dir)
            content = _git_read_file(commit_a, str(rel))
            if content is None:
                print(f"::error::Could not read {rel} from {commit_a}", file=sys.stderr)
                sys.exit(1)
            p.write_text(content)

        print("Evaluating old closure...", file=sys.stderr)
        old_pkgs = show_closure()
        print(f"  {len(old_pkgs)} packages", file=sys.stderr)

        for p, c in zip(locks, saved):
            p.write_text(c)

        print("Evaluating new closure...", file=sys.stderr)
        new_pkgs = show_closure()
        print(f"  {len(new_pkgs)} packages", file=sys.stderr)

    finally:
        for p, c in zip(locks, saved):
            p.write_text(c)

    entries = diff_packages(old_pkgs, new_pkgs)
    pkg_map = load_pkg_map(PKG_MAP)

    nixpkgs_rev = _parse_flake_rev(saved[0])
    if nixpkgs_rev is None:
        print("::error::Could not extract nixpkgs revision from flake.lock", file=sys.stderr)
        sys.exit(1)
    buckets = _classify_entries(entries, pkg_map, nixpkgs_rev)

    if not any([
        buckets["changes"], buckets["added"], buckets["removed"],
        buckets["unmapped"], buckets["eval_errors"],
    ]):
        print("No changes detected. Skipping.", file=sys.stderr)
        sys.exit(0)

    today = date.today().isoformat()
    owner = _repo_owner()
    body = format_issue(commit_a, commit_b, buckets, owner)
    body = redirect_github(body)

    if args.output:
        args.output.write_text(body)
        print(f"Written to {args.output}", file=sys.stderr)
    else:
        title = f"[{today}] Package Update Report: {commit_a[:7]} \u2192 {commit_b[:7]}"
        subprocess.run(
            ["gh", "issue", "create", "--label", "package-changes", "--title", title, "--body", body],
            check=True,
        )
        print("Issue created.", file=sys.stderr)


if __name__ == "__main__":
    main()
