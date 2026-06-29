# Shared helpers for upstream-check: GitHub session, pagination, parameter
# validation, the hidden YAML block parsed from issue bodies, and a redirect
# URL helper that avoids creating backlinks on upstream repos.

import re
import requests
import yaml

API = "https://api.github.com"
BLOCK_KEY = "upstream-check"
COMMENT_RE = re.compile(r"<!--(.*?)-->", re.DOTALL)


def create_session(token):
    s = requests.Session()
    s.headers.update({
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    })
    return s


def paginate(s, path, params=None, cap_pages=None):
    # Follow Link rel=next up to cap_pages (bounds calls for list endpoints).
    # GitHub's Link header carries per_page forward, so params only apply on
    # the first request.
    url = f"{API}{path}"
    out, page = [], 0
    while url and (cap_pages is None or page < cap_pages):
        r = s.get(url, params=params if page == 0 else None, timeout=30)
        r.raise_for_status()
        out.extend(r.json())
        url = r.links.get("next", {}).get("url")
        page += 1
    return out


def require(params, keys):
    # Validate that a flat list of keys is present in params.
    # Returns None when all present, otherwise a stable detail string the
    # checker returns directly without raising. Keys are checked verbatim, so
    # each checker fully owns its own parameter names.
    missing = [k for k in keys if k not in params]
    if missing:
        return f"missing required field(s): {', '.join(missing)}"
    return None


def parse_check_block(body):
    # The upstream-check block must be the first thing in the body (leading
    # whitespace tolerated). Only the first HTML comment is honoured, so a
    # stray YAML snippet elsewhere in the body can't masquerade as params.
    stripped = (body or "").lstrip()
    m = COMMENT_RE.match(stripped)
    if not m:
        return {}
    try:
        data = yaml.safe_load(m.group(1))
    except yaml.YAMLError:
        return {}
    if isinstance(data, dict) and BLOCK_KEY in data:
        v = data[BLOCK_KEY]
        if isinstance(v, dict):
            return v
    return {}


def gh_redirect(owner, repo, kind, id):
    # Build a redirect.github.com URL that links to an upstream resource
    # without generating a backlink on the upstream issue/PR. Checkers MUST
    # use this (instead of github.com) whenever they emit an upstream URL in
    # the detail string.
    #   kind: github path segment(s) such as "issues", "pull",
    #         "releases/tag", "releases", or "tree".
    #   id:   the number / tag / ref; pass "" for list views (e.g. releases).
    tail = f"{kind}/{id}" if id else kind
    return f"https://redirect.github.com/{owner}/{repo}/{tail}"
