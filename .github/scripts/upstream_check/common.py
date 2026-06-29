# Shared helpers for upstream-check: GitHub session, pagination, and the
# hidden YAML block parsed from issue bodies.

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
    url = f"{API}{path}"
    out, page = [], 0
    while url and (cap_pages is None or page < cap_pages):
        r = s.get(url, params=params if page == 0 else None, timeout=30)
        r.raise_for_status()
        out.extend(r.json())
        url = r.links.get("next", {}).get("url")
        page += 1
    return out


def parse_check_block(body):
    # First HTML comment whose YAML is a mapping with our key. Flat params
    # live directly under that key (e.g. repo / target).
    for m in COMMENT_RE.finditer(body or ""):
        try:
            data = yaml.safe_load(m.group(1))
        except yaml.YAMLError:
            continue
        if isinstance(data, dict) and BLOCK_KEY in data:
            v = data[BLOCK_KEY]
            if isinstance(v, dict):
                return v
    return {}
