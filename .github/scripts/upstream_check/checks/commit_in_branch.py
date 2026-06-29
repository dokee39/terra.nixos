# Satisfied when a commit SHA is already in a branch (or tag) ref.
# compare/{base}...{head} reports `status` from head's perspective:
#   base = sha, head = branch
#   ahead      -> branch is a descendant of sha (sha is in branch history)
#   identical  -> branch tip == sha
#   behind/diverged -> sha not in branch
# So satisfied iff status in {ahead, identical}.

import re

from common import API, require, gh_redirect

SHA_RE = re.compile(r"^[0-9a-fA-F]{40}$")


def check(params, s):
    err = require(params, ["repo", "branch", "sha"])
    if err:
        return False, err
    repo = params["repo"]
    owner, _, repo_name = repo.partition("/")
    branch = str(params["branch"]).strip()
    sha = str(params["sha"]).strip()
    if not SHA_RE.match(sha):
        return False, "`sha` must be a full 40-char commit SHA."
    r = s.get(f"{API}/repos/{repo}/compare/{sha}...{branch}", timeout=30)
    if r.status_code == 404:
        return False, f"ref `{sha}` or `{branch}` not found in {repo}."
    r.raise_for_status()
    status = r.json().get("status")
    link = gh_redirect(owner, repo_name, "tree", branch)
    if status in ("ahead", "identical"):
        return True, f"commit {sha[:7]} is in `{branch}` ([ref]({link}))."
    return False, f"commit {sha[:7]} not yet in `{branch}` (compare status: {status})."
