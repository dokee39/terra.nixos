# Satisfied when an upstream GitHub issue is closed. The /issues endpoint
# also returns PRs, so the detail notes when a number looks like a PR and
# points the user at upstream:pr_merged for the "merged" semantics.

from common import API, require, gh_redirect


def check(params, s):
    err = require(params, ["repo", "number"])
    if err:
        return False, err
    repo = params["repo"]
    owner, _, repo_name = repo.partition("/")
    try:
        number = int(params["number"])
    except (TypeError, ValueError):
        return False, f"invalid issue number `{params['number']!r}`."
    r = s.get(f"{API}/repos/{repo}/issues/{number}", timeout=30)
    if r.status_code == 404:
        return False, f"issue {repo}#{number} not found."
    r.raise_for_status()
    data = r.json()
    state = data.get("state")
    link = gh_redirect(owner, repo_name, "issues", str(number))
    suffix = ""
    if "pull_request" in data:
        suffix = " (this is a PR; use `upstream:pr_merged` for merged semantics)"
    if state == "closed":
        return True, f"[{repo}#{number}]({link}) is closed{suffix}."
    return False, f"[{repo}#{number}]({link}) is still open{suffix}."
