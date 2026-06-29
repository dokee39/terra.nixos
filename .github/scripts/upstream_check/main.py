# Track local overrides blocked on upstream changes. Each tracked issue
# carries a check label (e.g. `upstream:release_version`); the matching
# check inspects a flat YAML block hidden in the issue body. When every
# active check on an issue is satisfied, comment (@owner @author), remove the
# satisfied check labels, and add `upstream:resolved` so the issue stops
# being tracked. When an `upstream:*` label has no matching checker, add
# `upstream:unknown-check` and comment once to @mention the owner. The
# script never adds check labels itself; those come from the issue template
# or by hand.

import importlib
import logging
import os
import pkgutil
import sys
from urllib.parse import quote

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import common

log = logging.getLogger("upstream-check")

# Flow labels managed by this script. Check labels (upstream:<checker>) are
# never added here; only the two markers below.
RESOLVED_LABEL = "upstream:resolved"
UNKNOWN_LABEL = "upstream:unknown-check"
OTHER_LABEL = "upstream:other"
LABEL_PREFIX = "upstream:"

UNKNOWN_INTRO = (
    "@{owner} issue #{number} carries upstream label(s) with no matching "
    "checker:\n\n{items}\n\n"
    "Either rename to a known `upstream:<checker>` label, or add a "
    "`checks/<name>.py` exposing `check`. Once resolved, the "
    f"`{UNKNOWN_LABEL}` marker is removed automatically."
)


def discover():
    # Scan checks/ for modules exposing a callable `check`. The label that
    # routes an issue to the module is `upstream:<module_name>`, so duplicate
    # labels are impossible at the filesystem level.
    import checks
    registry = {}
    for _, name, _ in pkgutil.iter_modules(checks.__path__):
        m = importlib.import_module(f"checks.{name}")
        if callable(getattr(m, "check", None)):
            registry[f"{LABEL_PREFIX}{name}"] = m
    return registry


def active_checks(issue, registry):
    # (label, module) pairs for the issue's known upstream:* check labels.
    names = {lab["name"] for lab in issue["labels"]}
    return [(n, registry[n]) for n in names if n in registry]


def unknown_labels(issue, registry):
    # upstream:* (excluding the two flow markers) with no matching checker.
    names = {lab["name"] for lab in issue["labels"]}
    return sorted(
        n for n in names
        if n.startswith(LABEL_PREFIX)
        and n not in (RESOLVED_LABEL, UNKNOWN_LABEL, OTHER_LABEL)
        and n not in registry
    )


def reconcile_unknown(issue, repo, owner, registry, s, dry):
    # Keep UNKNOWN_LABEL in sync with the presence of unknown upstream:*
    # labels: add it (and notify once) when one appears; remove it once none
    # remain. This is orthogonal to running actual checks, so it lives here
    # rather than inline in the main processing flow.
    names = {lab["name"] for lab in issue["labels"]}
    has_marker = UNKNOWN_LABEL in names
    unknown = unknown_labels(issue, registry)
    number = issue["number"]
    if unknown and not has_marker:
        log.warning("issue #%s: unknown upstream labels %s; tagging + notifying", number, unknown)
        if dry:
            return
        s.post(
            f"{common.API}/repos/{repo}/issues/{number}/labels",
            json={"labels": [UNKNOWN_LABEL]}, timeout=30,
        ).raise_for_status()
        notify_unknown(issue, repo, owner, unknown, s, dry)
    elif not unknown and has_marker:
        log.info("issue #%s: unknown labels resolved; removing marker", number)
        if dry:
            return
        d = s.delete(
            f"{common.API}/repos/{repo}/issues/{number}/labels/{quote(UNKNOWN_LABEL)}",
            timeout=30,
        )
        if d.status_code != 404:
            d.raise_for_status()


def notify_unknown(issue, repo, owner, unknown, s, dry):
    # One-time @mention so the owner learns about the mismatch. The
    # UNKNOWN label doubles as the "already notified" flag, so this fires at
    # most once per unknown episode.
    number = issue["number"]
    items = "\n".join(f"- `{n}`" for n in unknown)
    body = UNKNOWN_INTRO.format(owner=owner, number=number, items=items)
    if dry:
        log.info("[dry-run] #%s would comment notifying @%s:\n%s", number, owner, body)
        return
    s.post(
        f"{common.API}/repos/{repo}/issues/{number}/comments",
        json={"body": body}, timeout=30,
    ).raise_for_status()


def run_checks(block, active, s):
    # Flat params: the whole upstream-check block is passed to each active
    # check; the label already routed to the right check. Framework-level
    # error handling keeps one failing checker from aborting the rest.
    results = []
    for lab, mod in active:
        try:
            results.append((lab, mod.check(block, s)))
        except Exception:
            log.exception("%s failed", lab)
            results.append((lab, (False, "check raised an exception; see logs")))
    return results


def all_satisfied(results):
    # Pure predicate. No conditions means undecided -> not satisfied.
    return bool(results) and all(ok for _, (ok, _) in results)


def build_resolution_comment(issue, owner, results):
    lines = [f"@{issue['user']['login']} @{owner} upstream conditions are now met:", ""]
    # The bullet introduces the checker's detail on its own line, so a
    # checker may return a multi-line body without breaking the list shape.
    for lab, (_, why) in results:
        lines += [f"- **{lab}**:", why]
    lines += ["", "Please verify the local override can be removed and close this issue."]
    return "\n".join(lines)


def apply_resolution(issue, repo, owner, results, s, dry):
    # Pure side effects: comment, drop satisfied check labels, add resolved
    # marker. Idempotent via the label swap on subsequent runs (resolved
    # issue no longer carries active check labels).
    number = issue["number"]
    body = build_resolution_comment(issue, owner, results)
    if dry:
        log.info("[dry-run] #%s would comment and swap labels to %s:\n%s",
                 number, RESOLVED_LABEL, body)
        return
    s.post(
        f"{common.API}/repos/{repo}/issues/{number}/comments",
        json={"body": body}, timeout=30,
    ).raise_for_status()
    for lab, _ in results:
        d = s.delete(
            f"{common.API}/repos/{repo}/issues/{number}/labels/{quote(lab)}",
            timeout=30,
        )
        if d.status_code != 404:
            d.raise_for_status()
    s.post(
        f"{common.API}/repos/{repo}/issues/{number}/labels",
        json={"labels": [RESOLVED_LABEL]}, timeout=30,
    ).raise_for_status()
    log.info("issue #%s resolved; labels -> %s", number, RESOLVED_LABEL)


def process(issue, s, repo, owner, registry, dry):
    reconcile_unknown(issue, repo, owner, registry, s, dry)
    active = active_checks(issue, registry)
    if not active:
        return
    block = common.parse_check_block(issue["body"])
    if not block:
        log.warning("issue #%s has check label but no upstream-check block", issue["number"])
        return
    results = run_checks(block, active, s)
    if not all_satisfied(results):
        if results:
            blocked = "; ".join(f"{lab}: {why}" for lab, (ok, why) in results if not ok)
            log.info("issue #%s still blocked: %s", issue["number"], blocked)
        return
    apply_resolution(issue, repo, owner, results, s, dry)


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s")
    token = os.environ.get("GH_TOKEN")
    repo = os.environ.get("GH_REPOSITORY")
    dry = os.environ.get("UPSTREAM_CHECK_DRY_RUN", "").lower() in ("1", "true")
    if not token or not repo:
        log.error("GH_TOKEN and GH_REPOSITORY are required")
        sys.exit(2)
    owner = repo.split("/", 1)[0]
    s = common.create_session(token)
    registry = discover()
    if not registry:
        log.warning("no checks discovered")
        return
    for issue in common.paginate(
        s, "/repos/" + repo + "/issues",
        {"state": "open", "per_page": 100}, cap_pages=2,
    ):
        if "pull_request" in issue:
            continue
        try:
            process(issue, s, repo, owner, registry, dry)
        except Exception:
            log.exception("processing issue #%s failed", issue.get("number"))


if __name__ == "__main__":
    main()
