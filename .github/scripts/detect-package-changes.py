#!/usr/bin/env python3
"""Build two closures, diff packages, classify, create issue."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Optional

import yaml

FLAKE = Path(__file__).resolve().parent.parent.parent / ".github" / "tests" / "test-flake"
PKG_MAP = FLAKE.parent.parent / "config" / "pkg-map.yaml"

SYSTEM_PROMPT = """You are a NixOS package update analyst. Analyze a single package version
change and write a concise analysis in English.

## Output constraints

- Output ONLY the analysis body. No greeting, sign-off, or prefix.
- No markdown headings.
- Use markdown inline formatting: bold, `code`, [links]().
- One-sentence: just one line. Detailed: under 200 words.

## Detail level \u2014 decide per package

Write **detailed analysis** when ANY condition is true:

1. **Downgrade**: explain likely reason (packaging revert, dependency
   rebuild, upstream breakage).
2. **Breaking change / behavior change**: describe impact and what user
   must do (config format change, service deprecation, CLI change, etc.).
3. **Security fix**: mention CVEs found, assess severity. Minor or non-\
exploitable CVEs can be brief.
4. **New feature worth noting**: describe what user might want to use or
   configure.

Otherwise write exactly ONE sentence stating the version change and that
it is a routine update with no expected impact.

## Finding information

Use web search to find changelogs or release notes.
- Check the Homepage \u2014 look for Releases, CHANGELOG, or NEWS.
- Confirm security fixes via search. Do NOT invent.

## Prohibitions

- Do NOT invent CVEs, changelogs, or breaking changes you are unsure of.
- Do NOT repeat the package name or status.
- Do NOT speculate about user\'s hardware, config, or setup.
- Do NOT use emoji.
"""


def nix(cmd: list[str], **kwargs: Any) -> str:
    return subprocess.run(
        cmd, capture_output=True, text=True, check=True, **kwargs
    ).stdout.strip()


def build_closure(rev: str) -> str:
    nix(
        [
            "nix", "flake", "lock", "--override-input", "nixpkgs",
            f"github:NixOS/nixpkgs/{rev}",
        ],
        cwd=str(FLAKE),
    )
    return nix(
        [
            "nix", "build",
            ".#nixosConfigurations.ci-diff.config.system.build.toplevel",
            "--no-link", "--print-out-paths",
        ],
        cwd=str(FLAKE),
    )


def _parse_version_event(v: dict) -> dict:
    kind = v["kind"]
    ev = {"kind": kind}
    if kind == "changed":
        ev["old_name"] = v["old"]["name"]
        ev["old_amount"] = v["old"]["amount"]
        ev["new_name"] = v["new"]["name"]
        ev["new_amount"] = v["new"]["amount"]
    elif kind in ("added", "removed"):
        ev["name"] = v["version"]["name"]
        ev["amount"] = v["version"]["amount"]
    elif kind == "amount_changed":
        ev["name"] = v["version"]["name"]
        ev["old_amount"] = v["old_amount"]
        ev["new_amount"] = v["new_amount"]
    return ev


def parse_dix(raw: str) -> list[dict]:
    data = json.loads(raw)
    entries = []
    for d in data.get("diffs", []):
        versions = [_parse_version_event(v) for v in d.get("versions", [])]
        entries.append({
            "name": d["name"],
            "status": d["status"],
            "versions": versions,
            "selection": d["selection"],
            "size_old": d["size_old"],
            "size_new": d["size_new"],
            "size_delta": d["size_delta"],
        })
    return entries


def load_pkg_map(path: Path) -> dict:
    raw = yaml.safe_load(path.read_text())
    return {k: v for k, v in (raw or {}).items()}


def is_url(s: Any) -> bool:
    return isinstance(s, str) and (
        s.startswith("http://") or s.startswith("https://")
    )


def redir_github(url: Optional[str]) -> Optional[str]:
    if not url:
        return url
    return url.replace("github.com", "redirect.github.com")


def resolve_path(p: str) -> str:
    path = Path(p)
    if path.is_symlink():
        path = path.resolve()
    resolved = str(path)
    if not resolved.startswith("/nix/store/"):
        print(f"Error: '{p}' does not resolve to /nix/store/...", file=sys.stderr)
        sys.exit(1)
    return resolved


def extract_hash(store_path: str) -> str:
    return store_path.strip().split("/")[-1].split("-")[0]


def run_dix_human(old_path: str, new_path: str) -> Optional[str]:
    """Run dix human-readable, pipe through aha, return HTML <pre>."""
    try:
        dix_out = subprocess.run(
            ["nix", "run", "nixpkgs#dix", "--", "--color", "always", old_path, new_path],
            capture_output=True, text=True, check=True,
        ).stdout
        aha_out = subprocess.run(
            ["nix", "run", "nixpkgs#aha", "--"],
            input=dix_out, capture_output=True, text=True, check=True,
            timeout=30,
        ).stdout
        start = aha_out.find("<pre>")
        end = aha_out.find("</pre>")
        if start != -1 and end != -1:
            return aha_out[start:end + len("</pre>")]
        return aha_out.strip()
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return None


def version_summary(versions: list[dict]) -> str:
    parts = []
    for v in versions:
        k = v["kind"]
        if k == "changed":
            parts.append(f"{v['old_name']} \u2192 {v['new_name']}")
        elif k == "added":
            parts.append(f"+{v['name']}")
        elif k == "removed":
            parts.append(f"-{v['name']}")
        elif k == "amount_changed":
            parts.append(
                f"{v['name']} ({v['old_amount']}\u2192{v['new_amount']})"
            )
    return ", ".join(parts)


def eval_meta(attr: str, rev: str) -> tuple[Optional[str], Optional[str]]:
    try:
        out = nix(
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
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None, None


def call_groq(client: OpenAI, pkg: dict) -> str:
    prompt = f"""Package: {pkg['name']}
Status: {pkg['status']}
Version changes: {pkg['version_summary']}
Homepage: {pkg.get('homepage') or '(not available)'}
Description: {pkg.get('description') or '(not available)'}"""
    for attempt in range(3):
        try:
            resp = client.chat.completions.create(
                model="groq/compound-mini",
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": prompt},
                ],
                temperature=0.3,
                max_tokens=300,
                timeout=30,
            )
            return resp.choices[0].message.content.strip()
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2 ** attempt)


def format_issue(old_rev: str, new_rev: str, stats: dict, changes: list, unmapped: list, eval_errors: list, dix_html: Optional[str] = None) -> str:
    lines = [
        f"# Package Update Report: {old_rev[:7]} \u2192 {new_rev[:7]}",
        "",
        f"{stats['total']} packages changed "
        f"({stats['upgraded']} upgraded, {stats['mixed']} mixed, "
        f"{stats['downgraded']} downgraded, {stats['removed']} removed, "
        f"{stats['added']} added)",
        "",
    ]

    if changes:
        lines.append("## Changes")
        lines.append("")
        for c in changes:
            lines.append(f"### {c['name']}")
            lines.append("")
            lines.append(f"**Status:** {c['status']} {c['version_summary']}")
            if c.get("homepage"):
                lines.append(f"**Homepage:** {c['homepage']}")
            if c.get("description"):
                lines.append(f"**Description:** {c['description']}")
            if c.get("analysis"):
                lines.append("")
                lines.append(c["analysis"])
            lines.append("")

    if unmapped or eval_errors:
        lines.append("## Errors")
        lines.append("")

        if unmapped:
            lines.append("### Unmapped")
            lines.append("")
            lines.append("| name (dix) | status |")
            lines.append("|------------|--------|")
            for u in unmapped:
                lines.append(f"| {u['name']} | {u['status']} |")
            lines.append("")
            lines.append(
                "Add entries to `.github/config/pkg-map.yaml` "
                "to enable analysis."
            )
            lines.append("")

        if eval_errors:
            lines.append("### Eval Errors")
            lines.append("")
            lines.append("| attr | error |")
            lines.append("|------|-------|")
            for e in eval_errors:
                lines.append(f"| {e['attr']} | {e['error']} |")
            lines.append("")

    if dix_html:
        lines.append("## Full Diff")
        lines.append("")
        lines.append("<details>")
        lines.append("<summary>dix human-readable output</summary>")
        lines.append("")
        lines.append(dix_html)
        lines.append("")
        lines.append("</details>")
        lines.append("")

    return "\n".join(lines)


def _inc_stat(stats: dict, status: str) -> None:
    stats[status.lower()] += 1
    stats["total"] += 1


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("old_ref", help="nixpkgs revision or store path (with --local)")
    parser.add_argument("new_ref", help="nixpkgs revision or store path (with --local)")
    parser.add_argument("--local", action="store_true", help="use store paths instead of building")
    parser.add_argument("-o", "--output", type=Path, help="write issue body to file")
    parser.add_argument("--skip-ai", action="store_true", help="skip Groq AI analysis")
    args = parser.parse_args()

    if args.local:
        old_path = resolve_path(args.old_ref)
        new_path = resolve_path(args.new_ref)
        ref_a = extract_hash(old_path)[:7]
        ref_b = extract_hash(new_path)[:7]
    else:
        ref_a, ref_b = args.old_ref, args.new_ref
        print("Building old closure...", file=sys.stderr)
        old_path = build_closure(ref_a)
        print(f"  {old_path}", file=sys.stderr)
        print("Building new closure...", file=sys.stderr)
        new_path = build_closure(ref_b)
        print(f"  {new_path}", file=sys.stderr)

    print("Running dix...", file=sys.stderr)
    dix_raw = nix(
        ["nix", "run", "nixpkgs#dix", "--", "--output", "json", old_path, new_path]
    )

    print("Running dix (human)...", file=sys.stderr)
    dix_html = run_dix_human(old_path, new_path)

    entries = parse_dix(dix_raw)
    pkg_map = load_pkg_map(PKG_MAP)

    changes = []
    unmapped = []
    eval_errors = []
    stats = {
        "upgraded": 0, "mixed": 0, "downgraded": 0,
        "removed": 0, "added": 0, "total": 0,
    }

    for e in entries:
        status = e["status"]
        if status == "Changed":
            continue
        if status in ("Added", "Removed"):
            _inc_stat(stats, status)
            continue

        # status is Upgraded, Mixed, or Downgraded
        mapping = pkg_map.get(e["name"])

        if mapping is None:
            unmapped.append(e)
            _inc_stat(stats, status)
            continue

        if mapping is False:
            continue

        _inc_stat(stats, status)

        entry = {
            "name": e["name"],
            "status": status,
            "version_summary": version_summary(e["versions"]),
            "homepage": None,
            "description": None,
        }

        if is_url(mapping):
            entry["homepage"] = redir_github(mapping)
        elif not args.local:
            print(f"  eval {mapping}...", file=sys.stderr)
            desc, hp = eval_meta(mapping, args.new_ref)
            if desc is None and hp is None:
                eval_errors.append({
                    "attr": mapping, "error": "nix eval failed"
                })
            entry["description"] = desc
            entry["homepage"] = redir_github(hp)

        changes.append(entry)

    if not args.skip_ai:
        print("Running AI analysis...", file=sys.stderr)
        from openai import OpenAI
        api_key = os.environ.get("GROQ_API_KEY")
        if not api_key:
            print("Error: GROQ_API_KEY environment variable not set", file=sys.stderr)
            sys.exit(1)
        client = OpenAI(
            api_key=api_key,
            base_url="https://api.groq.com/openai/v1",
        )
        for c in changes:
            print(f"  {c['name']}...", file=sys.stderr)
            try:
                analysis = call_groq(client, c)
                c["analysis"] = redir_github(analysis)
            except Exception as e:
                c["analysis"] = f"*Analysis failed: {e}*"

    body = format_issue(ref_a, ref_b, stats, changes, unmapped, eval_errors, dix_html)

    if args.output:
        args.output.write_text(body)
        print(f"Written to {args.output}", file=sys.stderr)
    else:
        title = f"Package Update Report: {ref_a} \u2192 {ref_b}"
        subprocess.run(
            ["gh", "issue", "create", "--title", title, "--body", body],
            check=True,
        )
        print("Issue created.", file=sys.stderr)


if __name__ == "__main__":
    main()
