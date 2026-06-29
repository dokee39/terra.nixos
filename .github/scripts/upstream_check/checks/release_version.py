# Satisfied when upstream publishes a release tag satisfying a version
# constraint. A bare version defaults to >=. Prereleases are skipped unless
# the target itself is a prerelease.

from packaging.version import InvalidVersion, Version

from common import paginate, require, gh_redirect

RELEASE_PAGES = 3


def check(params, s):
    err = require(params, ["repo", "target"])
    if err:
        return False, err
    repo = params["repo"]
    owner, _, repo_name = repo.partition("/")
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
    for rel in paginate(s, f"/repos/{repo}/releases", {"per_page": 100}, cap_pages=RELEASE_PAGES):
        tag = rel.get("tag_name") or ""
        try:
            v = Version(tag.removeprefix("v").removeprefix("V"))
        except InvalidVersion:
            continue
        if not want_v.is_prerelease and v.is_prerelease:
            continue
        if (v >= want_v) if op == ">=" else (v > want_v):
            return (
                True,
                f"upstream {repo} released [`{tag}`]"
                f"({gh_redirect(owner, repo_name, 'releases/tag', tag)})"
                f" satisfying `{t}`.",
            )
    return False, f"no release of {repo} satisfies `{t}` yet."
