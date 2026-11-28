---
description: Review code changes or files for bugs, security, performance, and design quality.
argument-hint: "<files, diff, or PR URL>"
---
Review: $ARGUMENTS

1. Load the `coding` skill. Read the full affected functions or files, plus relevant callers, entry points, and tests.
2. Check for logic bugs, broken assumptions, state or concurrency issues, and unhandled external failures; security flaws at external boundaries (unvalidated input, injection, auth gaps, exposed secrets); and real performance or resource problems (N+1 queries, unbounded memory growth or loops, blocking calls on hot paths, leaked handles).
3. Check against the `coding` skill for bypassed existing helpers, leftover parallel paths from partial migrations, outdated names, unneeded abstractions, redundant defensive code, and weak or over-mocked tests. Do not ask for redundant internal checks, extra layers, or cold-path micro-optimizations.
4. If tests or build fail, account for those failures.
5. Report only concrete issues with real impact, ordered High to Low as `[High|Medium|Low] file:line — issue and impact`; if there are no real issues, say so plainly.
6. Keep the review read-only.
