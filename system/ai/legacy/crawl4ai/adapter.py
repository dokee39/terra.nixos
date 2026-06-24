"""
Firecrawl-compatible API adapter backed by Crawl4AI.

Start Crawl4AI first, then run::

    uvicorn main:app --host 127.0.0.1 --port 3002

Then point LibreChat's ``firecrawlApiUrl`` to ``http://127.0.0.1:3002``::

    # .env / librechat.yaml
    FIRECRAWL_API_URL=http://127.0.0.1:3002
    FIRECRAWL_API_KEY=unused

Endpoints
---------
``POST /v1/scrape``   Firecrawl v1-compatible scrape
``POST /v2/scrape``   Firecrawl v2-compatible scrape  (also aliased as ``/scrape``)
``GET  /health``      health check + Crawl4AI reachability

Configuration
-------------
``CRAWL4AI_BASE_URL``  env var, defaults to ``http://localhost:11235``

Unsupported parameters
----------------------
The adapter rejects requests containing these Firecrawl features with a 400
error, since Crawl4AI has no equivalent:

  ``parsePDF``, ``actions``, ``onlyCleanContent``, ``changeTrackingOptions``

Parameter mapping (Firecrawl → Crawl4AI)
----------------------------------------
====================  ===============================  ========
Firecrawl             Crawl4AI                         Notes
====================  ===============================  ========
``url``               ``urls: [url]``
``formats: [md]``     default markdown output
``onlyMainContent``   ``PruningContentFilter`` (fit)   default for both
``timeout``           ``page_timeout``
``waitFor`` (ms)      ``delay_before_return_html`` (s) cast to seconds
``waitFor`` (str)     ``wait_for``                     CSS selector / JS
``headers``           ``BrowserConfig.headers``        custom HTTP headers
``mobile``            ``viewport: {375, 812}``         mobile viewport
``skipTlsVerification`` ``verify_ssl: False``
``blockAds``          ``avoid_ads`` + ``remove_overlay_elements``
``excludeTags``       ``excluded_tags``                list of tag names
``includeTags``       ``target_elements``              list of CSS selectors
``location.languages`` ``Accept-Language`` header
``removeBase64Images``  default behaviour              no base64 in markdown
====================  ===============================  ========

Response format
---------------
Matches ``FirecrawlScrapeResponse``::

    {"success": true,
     "data": {"markdown": "...", "html": "...", "rawHtml": "...",
              "metadata": {"sourceURL": "...", "title": "...", ...}},
     "error": "..."}
"""

import os
import httpx
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

CRAWL4AI_URL = os.getenv("CRAWL4AI_BASE_URL", "http://localhost:11235")

app = FastAPI(title="firecrawl-adapter")


class UnsupportedParamError(ValueError):
    def __init__(self, params: list[str]):
        self.params = params
        super().__init__(
            f"unsupported parameters: {', '.join(params)}. "
            "These Firecrawl features have no Crawl4AI equivalent."
        )


def _to_crawl4ai(body: dict) -> dict | None:
    url = body.get("url")
    if not url:
        return None

    params = body.get("scrapeOptions", body)

    unsupported = []
    if params.get("parsePDF"):
        unsupported.append("parsePDF")
    if params.get("actions"):
        unsupported.append("actions")
    if params.get("onlyCleanContent"):
        unsupported.append("onlyCleanContent")
    if params.get("changeTrackingOptions"):
        unsupported.append("changeTrackingOptions")
    if unsupported:
        raise UnsupportedParamError(unsupported)

    browser_params: dict[str, object] = {}
    if params.get("mobile"):
        browser_params["viewport"] = {"type": "dict", "value": {"width": 375, "height": 812}}
    if params.get("skipTlsVerification"):
        browser_params["verify_ssl"] = False
    if params.get("blockAds"):
        browser_params["avoid_ads"] = True

    custom_headers = params.get("headers")
    if custom_headers:
        browser_params["headers"] = {"type": "dict", "value": dict(custom_headers)}

    crawler_params: dict[str, object] = {"cache_mode": "bypass"}

    timeout = params.get("timeout")
    if timeout is not None:
        crawler_params["page_timeout"] = timeout

    wait_for = params.get("waitFor")
    if wait_for is not None:
        if isinstance(wait_for, (int, float)):
            crawler_params["delay_before_return_html"] = max(wait_for / 1000, 0.1)
        else:
            crawler_params["wait_for"] = wait_for

    if params.get("blockAds"):
        crawler_params["remove_overlay_elements"] = True

    exclude_tags = params.get("excludeTags")
    if exclude_tags:
        crawler_params["excluded_tags"] = exclude_tags

    include_tags = params.get("includeTags")
    if include_tags:
        crawler_params["target_elements"] = include_tags

    location = params.get("location")
    if isinstance(location, dict):
        lang = location.get("languages")
        if isinstance(lang, list) and lang:
            headers = dict(browser_params.get("headers", {}).get("value", {}))
            headers.setdefault("Accept-Language", ",".join(lang))
            browser_params["headers"] = {"type": "dict", "value": headers}

    return {
        "urls": [url],
        "browser_config": {"type": "BrowserConfig", "params": browser_params},
        "crawler_config": {"type": "CrawlerRunConfig", "params": crawler_params},
    }


def _extract_markdown(result: dict) -> str:
    raw = result.get("markdown", "")
    if isinstance(raw, str):
        return raw
    if isinstance(raw, dict):
        return (
            raw.get("raw_markdown")
            or raw.get("markdown_with_citations")
            or raw.get("fit_markdown")
            or ""
        )
    return ""


def _to_firecrawl(crawl4ai_data: dict, original_url: str) -> dict:
    if not crawl4ai_data.get("success"):
        return {"success": False, "error": crawl4ai_data.get("error", "crawl failed")}
    if not crawl4ai_data.get("results"):
        return {"success": False, "error": "crawl returned no results"}

    result = crawl4ai_data["results"][0]
    if not result.get("success"):
        return {"success": False, "error": result.get("error", "scrape failed")}

    meta = result.get("metadata") or {}
    title = meta.get("title") or ""
    description = meta.get("description") or ""

    markdown = _extract_markdown(result)

    if not title and isinstance(markdown, str):
        for line in markdown.lstrip().split("\n"):
            stripped = line.strip()
            if stripped.startswith("# ") and len(stripped) > 2:
                title = stripped[2:].strip()
                break

    return {
        "success": True,
        "data": {
            "markdown": markdown,
            "html": result.get("cleaned_html") or result.get("html") or "",
            "rawHtml": result.get("html") or "",
            "metadata": {
                "sourceURL": result.get("url", original_url),
                "url": result.get("url", original_url),
                "title": title,
                "description": description,
                "language": meta.get("language") or "",
                "statusCode": meta.get("status_code", 200),
            },
        },
    }


async def _handle_scrape(request: Request) -> JSONResponse:
    try:
        body = await request.json()
    except Exception:
        return JSONResponse({"success": False, "error": "invalid json"}, status_code=400)

    try:
        payload = _to_crawl4ai(body)
    except UnsupportedParamError as e:
        return JSONResponse(
            {"success": False, "error": str(e)},
            status_code=400,
        )
    if payload is None:
        return JSONResponse({"success": False, "error": "url is required"}, status_code=400)

    params = body.get("scrapeOptions", body)
    timeout_ms = params.get("timeout", 60000)
    timeout_sec = max(timeout_ms / 1000 + 15, 75)

    try:
        async with httpx.AsyncClient(timeout=timeout_sec) as client:
            resp = await client.post(f"{CRAWL4AI_URL}/crawl", json=payload)
            resp.raise_for_status()
            return JSONResponse(_to_firecrawl(resp.json(), body.get("url", "")))
    except httpx.TimeoutException:
        return JSONResponse(
            {"success": False, "error": "upstream timeout"}, status_code=504
        )
    except httpx.HTTPStatusError as e:
        detail = ""
        try:
            body = e.response.json()
            detail = body.get("detail") or body.get("error") or ""
        except Exception:
            pass
        if not detail:
            detail = (e.response.text or "")[:200]
        return JSONResponse(
            {"success": False, "error": f"upstream error ({e.response.status_code}): {detail}"},
            status_code=502,
        )
    except httpx.RequestError as e:
        return JSONResponse(
            {"success": False, "error": f"upstream unreachable: {e}"},
            status_code=502,
        )


@app.post("/v1/scrape")
async def scrape_v1(request: Request):
    return await _handle_scrape(request)


@app.post("/v2/scrape")
async def scrape_v2(request: Request):
    return await _handle_scrape(request)


@app.get("/health")
async def health():
    try:
        async with httpx.AsyncClient(timeout=5) as client:
            await client.get(f"{CRAWL4AI_URL}/health")
        return {"status": "ok", "crawl4ai": "reachable"}
    except Exception:
        return JSONResponse(
            {"status": "degraded", "crawl4ai": "unreachable"}, status_code=503
        )
