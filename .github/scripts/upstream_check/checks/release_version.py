# Satisfied when upstream publishes a release tag satisfying a version
# constraint. A bare version defaults to >=. Prereleases are skipped unless
# the target itself is a prerelease.

from packaging.version import InvalidVersion, Version

from common import paginate

LABEL = "upstream:release-version"


def check(params, s):
    repo = params["repo"]
    t = params["target"].strip()
    if t.startswith(">="):
        op, want = ">=", t[2:].strip()
    elif t.startswith(">"):
        op, want = ">", t[1:].strip()
    else:
        op, want = ">=", t
    want_v = Version(want)
    for rel in paginate(s, f"/repos/{repo}/releases", {"per_page": 100}, cap_pages=3):
        try:
            v = Version((rel.get("tag_name") or "").lstrip("vV"))
        except InvalidVersion:
            continue
        if not want_v.is_prerelease and v.is_prerelease:
            continue
        if (v >= want_v if op == ">=" else v > want_v):
            return True, f"upstream {repo} released `{rel['tag_name']}` satisfying `{t}`."
    return False, f"no release of {repo} satisfies `{t}` yet."
