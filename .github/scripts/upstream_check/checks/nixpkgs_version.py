# Satisfied when a nixpkgs channel ships a package version satisfying a
# version constraint. Version is read with `nix eval` against the upstream
# nixpkgs flake ref (github:NixOS/nixpkgs/<channel>), so the runner must
# have Nix installed -- the workflow installs it via cachix/install-nix-action.

import re
import subprocess

from packaging.version import InvalidVersion, Version

from common import require

EVAL_TIMEOUT = 180
PREFIX_RE = re.compile(r"^(?:unstable|git)-(.+)$")


def _eval_version(channel, attr):
    # Returns (version_str, None) on success or (None, stderr_summary) on
    # failure. `--raw` prints the string value bare; `.version` pins the attr
    # to the version string so `--raw` is always valid.
    ref = f"github:NixOS/nixpkgs/{channel}"
    try:
        out = subprocess.run(
            ["nix", "eval", f"{ref}#{attr}.version", "--raw", "--no-write-lock-file"],
            capture_output=True, text=True, timeout=EVAL_TIMEOUT,
        )
    except subprocess.TimeoutExpired:
        return None, f"nix eval timed out after {EVAL_TIMEOUT}s"
    if out.returncode != 0:
        return None, (out.stderr or "nix eval failed").strip()
    return out.stdout.strip(), None


def _parse_version(v):
    # nixpkgs versions are usually PEP440. A few bleeding-edge ones carry
    # `unstable-` / `git-` prefixes that packaging rejects wholesale; peel
    # the prefix and retry. Anything still unparseable (e.g. bare dates)
    # returns None so the caller surfaces it for human review instead of
    # silently mis-resolving.
    try:
        return Version(v)
    except InvalidVersion:
        m = PREFIX_RE.match(v)
        if m:
            try:
                return Version(m.group(1))
            except InvalidVersion:
                pass
        return None


def check(params, s):
    err = require(params, ["attr", "channel", "target"])
    if err:
        return False, err
    attr = params["attr"]
    channel = params["channel"]
    t = str(params["target"]).strip()
    if t.startswith(">="):
        op, want = ">=", t[2:].strip()
    elif t.startswith(">"):
        op, want = ">", t[1:].strip()
    else:
        op, want = ">=", t
    try:
        want_v = Version(want)
    except InvalidVersion:
        return False, f"unparseable target version `{want}`."
    got, eval_err = _eval_version(channel, attr)
    if eval_err:
        return False, f"`nix eval` of `{attr}` on `{channel}` failed: {eval_err}"
    got_v = _parse_version(got)
    if got_v is None:
        return False, (
            f"unparseable upstream version `{got}` for `{attr}` on `{channel}`; "
            f"resolve manually."
        )
    if not want_v.is_prerelease and got_v.is_prerelease:
        return False, (
            f"`{attr}` on `{channel}` is `{got}` (prerelease); "
            f"target `{t}` is stable, skipping."
        )
    if (got_v >= want_v) if op == ">=" else (got_v > want_v):
        link = (
            f"https://search.nixos.org/packages?channel={channel}&query={attr}"
        )
        return True, (
            f"`{attr}` on `{channel}` is `{got}`, satisfying `{t}` "
            f"([search]({link}))."
        )
    return False, f"`{attr}` on `{channel}` is `{got}`, does not satisfy `{t}`."
