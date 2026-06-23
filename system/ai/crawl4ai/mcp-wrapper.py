#!/usr/bin/env python3
"""Crawl4AI MCP wrapper — two tools: web_fetch and web_research."""

import argparse
import asyncio
import logging
import os

import httpx
from mcp.server.fastmcp import FastMCP
from openai import AsyncOpenAI

logger = logging.getLogger(__name__)

# ── CLI ───────────────────────────────────────────────────────
parser = argparse.ArgumentParser()
parser.add_argument("--port", type=int, default=11235)
parser.add_argument("--model", type=str, default="deepseek-chat")
parser.add_argument("--api-base", type=str, default="https://api.deepseek.com/v1")
_args = parser.parse_args()

CRAWL4AI_BASE = f"http://localhost:{_args.port}"
MODEL = _args.model
API_BASE = _args.api_base
API_KEY = os.environ.get("CRAWL4AI_WRAPPER_LLM_API_KEY", "")
CRAWL4AI_API_TOKEN = os.environ.get("CRAWL4AI_API_TOKEN", "")

_llm: AsyncOpenAI | None = None


def _get_llm() -> AsyncOpenAI:
    global _llm
    if _llm is None:
        _llm = AsyncOpenAI(api_key=API_KEY, base_url=API_BASE)
    return _llm

mcp = FastMCP(
    "crawl4ai-wrapper",
    instructions="""\
You have two tools for web content retrieval.

web_fetch — fetch and read a single page in full.
Use when you know the exact URL and need to read it completely
(documentation, articles, API references).

web_research — search across multiple pages with a query.
Use when you have several candidate URLs and need to find specific
information. The helper LLM filters out noise while keeping headings
intact so you can see what was skipped.

If web_research hides a section you need, fall back to web_fetch
to read that page in full.
""",
)

EXTRACTION_INSTRUCTIONS = """\
You are a research extraction assistant. Given raw markdown from multiple
web pages and an extraction query, restructure the content following these
rules:

1. REMOVE pure noise — elements that carry zero information value:
   navigation menus, cookie banners, theme toggles, "was this helpful" widgets,
   footer copyright, sidebar ads. Delete them entirely. Do not annotate.

2. PRESERVE all headings (# ## ### ####) from every page. Never delete a heading.

3. For sections whose content is IRRELEVANT to the extraction query:
   - Keep the heading
   - Replace the body with "[Content hidden: not relevant to query]"
   - Keep all sub-headings visible
   Example:
     ## Getting Started
     [Content hidden: not relevant to query]
     ### Prerequisites
     ### Installation
     ### Quick Start

4. For RELEVANT sections: keep the original content completely unchanged.
   Preserve code blocks, tables, lists, and all formatting.

5. For an ENTIRELY IRRELEVANT page:
   - Label: <=== Page N (URL) [Entire page hidden: not relevant to query] ===>
   - Still list all top-level headings from that page

6. If multiple pages share IDENTICAL boilerplate (same sidebar, same
   table of contents), consolidate them once at the top:
   <=== Shared Page Elements ===>
   Only do this when the boilerplate is truly identical across pages.

7. Return format:

<=== Shared Page Elements (if applicable) ===>
{merged boilerplate}

<=== Page 1 (URL1) ===>
{restructured content}

<=== Page 2 (URL2) ===>
{restructured content}

...

DO NOT add any text before the first <=== marker or after the last.
DO NOT summarize, paraphrase, or rewrite any preserved content.

Extraction query: """

# ── Tools ─────────────────────────────────────────────────────


@mcp.tool()
async def web_fetch(url: str) -> str:
    """Fetch a web page and return full Markdown content.

    Use for reading documentation, API references, articles — any single
    page you need to read completely. Returns unfiltered raw Markdown.

    Args:
       url: The URL to fetch (starts with http:// or https://).
    """
    try:
        async with httpx.AsyncClient(timeout=60) as client:
            headers = {}
            if CRAWL4AI_API_TOKEN:
               headers["Authorization"] = f"Bearer {CRAWL4AI_API_TOKEN}"
            resp = await client.post(
               f"{CRAWL4AI_BASE}/md",
               json={"url": url, "f": "raw"},
               headers=headers,
            )
            resp.raise_for_status()
            return resp.json()["markdown"]
    except httpx.HTTPStatusError as e:
        return f"Error fetching {url}: HTTP {e.response.status_code}"
    except httpx.TimeoutException:
        return f"Error fetching {url}: request timed out"
    except httpx.ConnectError:
        return f"Error fetching {url}: cannot connect to crawl4ai at {CRAWL4AI_BASE}"


@mcp.tool()
async def web_research(urls: list[str], extract_query: str) -> str:
    """Crawl multiple pages and extract information matching a query.

    Crawls all URLs, then a helper LLM restructures the content:
    keeps relevant sections unchanged, hides irrelevant ones while
    preserving their headings, and labels entirely irrelevant pages.
    Headings of hidden sections remain visible so you can decide
    whether to fetch those pages individually later.

    Args:
       urls: List of URLs to crawl.
       extract_query: What information to extract from the pages.
    """
    if not API_KEY:
        return "Error: CRAWL4AI_WRAPPER_LLM_API_KEY is not set"

    # ── Phase 1: concurrent crawl ──
    async def _fetch_one(url: str) -> tuple[str, str | None]:
        try:
            async with httpx.AsyncClient(timeout=60) as client:
                headers = {}
                if CRAWL4AI_API_TOKEN:
                    headers["Authorization"] = f"Bearer {CRAWL4AI_API_TOKEN}"
                resp = await client.post(
                    f"{CRAWL4AI_BASE}/md",
                    json={"url": url, "f": "raw"},
                    headers=headers,
                )
                resp.raise_for_status()
                return url, resp.json()["markdown"]
        except Exception as e:
            logger.warning("Failed to fetch %s: %s", url, e)
            return url, None

    results = await asyncio.gather(*[_fetch_one(u) for u in urls])

    parts: list[str] = []
    for i, (url, md) in enumerate(results, start=1):
        if md is None:
            parts.append(f"<=== Page {i} ({url}) [Failed to fetch] ===>\n")
        else:
            parts.append(f"<=== Page {i} ({url}) ===>\n\n{md}\n")

    raw_content = "\n".join(parts)

    # ── Phase 2: LLM extraction ──
    prompt = EXTRACTION_INSTRUCTIONS + extract_query + "\n\n--- RAW CONTENT ---\n" + raw_content

    try:
        client = _get_llm()
        response = await client.chat.completions.create(
            model=MODEL,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=16384,
        )
        return response.choices[0].message.content or ""
    except Exception as e:
        logger.error("LLM extraction failed: %s", e)
        return f"LLM extraction failed ({e}). Raw content:\n\n{raw_content}"


if __name__ == "__main__":
    mcp.run(transport="stdio")
