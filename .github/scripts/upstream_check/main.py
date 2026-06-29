# Track local overrides blocked on upstream changes. Each tracked issue carries
# a check label (e.g. `upstream:release-version`); the matching check inspects
# a flat YAML block hidden in the issue body. When every active check on an
# issue is satisfied, comment (@owner @author), then remove the satisfied check
# labels so the issue stops being tracked. No labels are added by this script.

import importlib
import logging
import os
import pkgutil
import sys
from urllib.parse import quote

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import common

log = logging.getLogger("upstream-check")


def discover():
    # Scan checks/ for modules exposing LABEL + check. Module short name is
    # the YAML key under upstream-check (see parse_check_block).
    import checks
    registry = {}
    for _, name, _ in pkgutil.iter_modules(checks.__path__):
        m = importlib.import_module(f"checks.{name}")
        lbl = getattr(m, "LABEL", None)
        if lbl and callable(getattr(m, "check", None)):
            if lbl in registry:
                raise RuntimeError(f"duplicate LABEL {lbl!r}")
            registry[lbl] = m
    return registry


def issue_active_labels(issue, registry):
    names = {lab["name"] for lab in issue["labels"]}
    return [(n, registry[n]) for n in names if n in registry]


def run_checks(block, active, s):
    # Flat params: the whole upstream-check block is passed to each active
    # check; the label already routed to the right check. Each check reads
    # only the keys it needs from the flat dict.
    results = []
    for lab, mod in active:
        try:
            results.append((lab, mod.check(block, s)))
        except Exception:
            log.exception("%s failed", lab)
    return results


def maybe_resolve(issue, repo, owner, results, s, dry):
    # Returns True once the labels have been swapped (caller logs the comment).
    if not results or not all(ok for _, (ok, _) in results):
        pending = "; ".join(f"{lab}: {why}" for lab, (ok, why) in results if not ok)
        log.info("issue #%s still blocked: %s", issue["number"], pending)
        return False
    lines = [f"@{issue['user']['login']} @{owner} upstream conditions are now met:", ""]
    lines += [f"- **{lab}** — {why}" for lab, (_, why) in results]
    lines += ["", "Please verify the local override can be removed and close this issue."]
    body = "\n".join(lines)
    number = issue["number"]
    if dry:
        log.info("[dry-run] #%s would comment:\n%s", number, body)
        return True
    p = s.post(f"{common.API}/repos/{repo}/issues/{number}/comments", json={"body": body}, timeout=30)
    p.raise_for_status()
    for lab, _ in results:
        d = s.delete(f"{common.API}/repos/{repo}/issues/{number}/labels/{quote(lab)}", timeout=30)
        if d.status_code != 404:
            d.raise_for_status()
    log.info("issue #%s resolved", number)
    return True


def process(issue, s, repo, owner, registry, dry):
    active = issue_active_labels(issue, registry)
    if not active:
        return
    block = common.parse_check_block(issue["body"])
    if not block:
        log.warning("issue #%s has check label but no upstream-check block", issue["number"])
        return
    results = run_checks(block, active, s)
    if not results:
        return
    maybe_resolve(issue, repo, owner, results, s, dry)


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s")
    token = os.environ.get("GH_TOKEN")
    repo = os.environ.get("GH_REPOSITORY")
    dry = os.environ.get("UPSTREAM_CHECK_DRY_RUN") in ("1", "true")
    if not token or not repo:
        log.error("GH_TOKEN and GH_REPOSITORY are required")
        sys.exit(2)
    owner = repo.split("/", 1)[0]
    s = common.create_session(token)
    registry = discover()
    if not registry:
        log.warning("no checks discovered")
        return
    for issue in common.paginate(s, "/repos/" + repo + "/issues", {"state": "open", "per_page": 100}, cap_pages=2):
        if "pull_request" in issue:
            continue
        try:
            process(issue, s, repo, owner, registry, dry)
        except Exception:
            log.exception("processing issue #%s failed", issue.get("number"))


if __name__ == "__main__":
    main()
