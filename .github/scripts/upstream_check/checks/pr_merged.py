# Satisfied when an upstream PR is closed AND merged. A PR closed without
# being merged (rejected) does NOT satisfy: the fix did not land.

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
        return False, f"invalid PR number `{params['number']!r}`."
    r = s.get(f"{API}/repos/{repo}/pulls/{number}", timeout=30)
    if r.status_code == 404:
        return False, f"PR {repo}#{number} not found."
    r.raise_for_status()
    data = r.json()
    link = gh_redirect(owner, repo_name, "pull", str(number))
    state = data.get("state")
    merged = bool(data.get("merged"))
    if state == "closed" and merged:
        return True, f"[PR {repo}#{number}]({link}) is merged."
    if state == "closed" and not merged:
        return False, (
            f"[PR {repo}#{number}]({link}) was closed without merge; "
            f"the fix did not land."
        )
    return False, f"[PR {repo}#{number}]({link}) is still open."
