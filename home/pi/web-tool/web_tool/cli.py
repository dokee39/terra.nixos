import argparse
import asyncio
import contextlib
import json
import logging
import os
import sys

from web_tool.filter_utils import filter_and_rank


MAX_RESPONSE_BYTES = 10 * 1024 * 1024


def fail(args, error_type, reason, **details):
    if args.json:
        print(json.dumps({"type": error_type, "reason": reason, **details}, ensure_ascii=False))
    else:
        print(f"Error: {reason}", file=sys.stderr)
    sys.exit(1)


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
        ref_url_threshold=0,
    )

    ctx = _CLI()
    results = await searcher.search(args.query, ctx, max_results=args.max_results)
    results = filter_and_rank(results)

    if not results and ctx.error_occurred:
        fail(args, "search_error", f"search failed: {ctx.last_error}")

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
        fail(args, "bad_scheme", f"unsupported URL scheme: {args.url}")

    from curl_cffi import requests
    from curl_cffi.curl import CURL_WRITEFUNC_ERROR
    import trafilatura

    body = bytearray()
    response_too_large = False

    def receive(chunk):
        nonlocal response_too_large
        if len(body) + len(chunk) > MAX_RESPONSE_BYTES:
            response_too_large = True
            return CURL_WRITEFUNC_ERROR
        body.extend(chunk)
        return len(chunk)

    try:
        resp = requests.get(
            args.url,
            timeout=60,
            impersonate="firefox",
            allow_redirects=True,
            content_callback=receive,
        )
        resp.raise_for_status()
        content_type = resp.headers.get("content-type", "").partition(";")[0].strip().lower()
        resp.content = bytes(body)
        text = resp.text

        unsupported_type = (
            content_type.startswith(("image/", "audio/", "video/", "font/", "model/"))
            or content_type == "application/pdf"
        )
        if unsupported_type or "\0" in text:
            reason = (
                f"unsupported content type: {content_type}"
                if unsupported_type
                else "binary content"
            )
            fail(args, "unsupported_content_type", reason)
    except requests.exceptions.HTTPError as e:
        status = e.response.status_code
        fail(args, "http_error", f"HTTP {status}", http_code=status)
    except requests.exceptions.Timeout:
        fail(args, "timeout", "request timed out after 60s")
    except requests.exceptions.ConnectionError:
        fail(args, "connection_error", f"cannot connect to {args.url}")
    except requests.exceptions.RequestException:
        if not response_too_large:
            raise
        fail(args, "response_too_large", "response exceeds 10 MiB limit")

    if content_type in ("text/html", "application/xhtml+xml"):
        markdown = trafilatura.extract(
            text,
            url=str(resp.url),
            output_format="markdown",
            include_comments=False,
            include_links=True,
            include_tables=True,
            include_images=False,
            with_metadata=True,
        )
    else:
        markdown = text.strip()
    if not markdown:
        fail(args, "no_content", "no extractable content found")
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
