import argparse
import asyncio
import contextlib
import json
import logging
import os
import sys

from web_tool.filter_utils import filter_and_rank


class _CLI:
    def __init__(self):
        self.error_occurred = False
        self.last_error = ""

    async def info(self, msg): ...

    async def error(self, msg):
        self.error_occurred = True
        self.last_error = msg
        print(f"[web-tool] error: {msg}", file=sys.stderr)


async def cmd_search(args):
    with open(os.devnull, "w") as devnull, contextlib.redirect_stderr(devnull):
        from duckduckgo_mcp_server.server import DuckDuckGoSearcher, SafeSearchMode

    logging.getLogger("httpx").setLevel(logging.WARNING)

    searcher = DuckDuckGoSearcher(
        safe_search=SafeSearchMode.MODERATE,
        default_region=args.region,
    )

    ctx = _CLI()
    results = await searcher.search(args.query, ctx, max_results=args.max_results)
    results = filter_and_rank(results)

    if not results and ctx.error_occurred:
        msg = f"search failed: {ctx.last_error}"
        if args.json:
            print(json.dumps({"type": "search_error", "reason": msg}, ensure_ascii=False))
        else:
            print(f"Warning: {msg}", file=sys.stderr)
        return

    if args.json:
        data = [
            {
                "title": r.title,
                "link": r.link,
                "snippet": r.snippet,
                "position": r.position,
            }
            for r in results
        ]
        print(json.dumps({"type": "results", "results": data}, indent=2, ensure_ascii=False))
    else:
        print(searcher.format_results_for_llm(results).strip())


def cmd_fetch(args):
    from urllib.parse import urlsplit

    if urlsplit(args.url).scheme not in ("http", "https"):
        if args.json:
            print(json.dumps({"type": "bad_scheme", "reason": f"unsupported URL scheme: {args.url}"}, ensure_ascii=False))
        else:
            print(f"Error: unsupported URL scheme: {args.url}", file=sys.stderr)
        sys.exit(1)

    from curl_cffi import requests
    import trafilatura

    try:
        resp = requests.get(
            args.url,
            timeout=60,
            impersonate="firefox",
            allow_redirects=True,
        )
        resp.raise_for_status()
        html = resp.text
    except requests.exceptions.HTTPError as e:
        status = e.response.status_code
        if args.json:
            print(json.dumps({"type": "http_error", "reason": f"HTTP {status}", "http_code": status}, ensure_ascii=False))
        else:
            print(f"Warning: HTTP {status}", file=sys.stderr)
        return
    except requests.exceptions.Timeout:
        if args.json:
            print(json.dumps({"type": "timeout", "reason": "request timed out after 60s"}, ensure_ascii=False))
        else:
            print(f"Warning: timeout: {args.url}", file=sys.stderr)
        return
    except requests.exceptions.ConnectionError:
        if args.json:
            print(json.dumps({"type": "connection_error", "reason": f"cannot connect to {args.url}"}, ensure_ascii=False))
        else:
            print(f"Warning: connection failed: {args.url}", file=sys.stderr)
        return

    markdown = trafilatura.extract(
        html,
        output_format="markdown",
        include_comments=False,
    )
    if not markdown:
        if args.json:
            print(json.dumps({"type": "no_content", "reason": "no extractable content found"}, ensure_ascii=False))
        else:
            print("Warning: no extractable content found", file=sys.stderr)
        return
    if args.json:
        print(json.dumps({"type": "content", "content": markdown.strip()}, ensure_ascii=False))
    else:
        print(markdown.strip())


def main():
    parser = argparse.ArgumentParser(prog="web-tool")
    sub = parser.add_subparsers(dest="command")

    sp = sub.add_parser("search", help="Search DuckDuckGo")
    sp.add_argument("query", help="search query string")
    sp.add_argument("-n", "--max-results", type=int, default=10)
    sp.add_argument(
        "-r", "--region",
        default=os.getenv("DDG_REGION", "us-en"),
        help="Region code (e.g. us-en, cn-zh, wt-wt)",
    )
    sp.add_argument("--json", action="store_true", help="Output JSON")

    fp = sub.add_parser("fetch", help="Fetch URL content and extract main text")
    fp.add_argument("url", help="URL to fetch (starts with http:// or https://)")
    fp.add_argument("--json", action="store_true", help="Output JSON")

    args = parser.parse_args()

    if args.command == "search":
        asyncio.run(cmd_search(args))
    elif args.command == "fetch":
        cmd_fetch(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
