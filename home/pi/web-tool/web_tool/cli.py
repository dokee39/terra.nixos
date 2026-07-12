import argparse
import asyncio
import contextlib
import logging
import os
import sys

from web_tool.filter_utils import filter_and_rank


class _CLI:
    async def info(self, msg): ...
    async def error(self, msg): ...


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

    if args.json:
        import json

        data = [
            {
                "title": r.title,
                "link": r.link,
                "snippet": r.snippet,
                "position": r.position,
            }
            for r in results
        ]
        print(json.dumps(data, indent=2, ensure_ascii=False))
    else:
        print(searcher.format_results_for_llm(results).strip())


def _fail(msg: str):
    print(msg, file=sys.stderr)
    sys.exit(1)


def cmd_fetch(args):
    from urllib.parse import urlsplit

    if urlsplit(args.url).scheme not in ("http", "https"):
        _fail(f"Error: unsupported URL scheme, only http/https allowed: {args.url}")

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
        _fail(f"Error: HTTP {e.response.status_code}")
    except requests.exceptions.Timeout:
        _fail(f"Error: request to {args.url} timed out")
    except requests.exceptions.ConnectionError:
        _fail(f"Error: cannot connect to {args.url}")
    except Exception as e:
        _fail(f"Error: {e}")

    markdown = trafilatura.extract(
        html,
        output_format="markdown",
        include_comments=False,
    )
    if not markdown:
        print(f"No extractable content from {args.url}", file=sys.stderr)
    print((markdown or "").strip())


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