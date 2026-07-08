---
description: Run tests and build, then review code for correctness, security, performance, and maintainability.
argument-hint: "<files, diff, or PR URL>"
---
Review: $ARGUMENTS

1. Determine the test and build commands (read README, package.json, or related config).
2. Run existing tests and build. Report any failures immediately.
3. Read all relevant code files in full (no truncation).
4. Analyze the code across these dimensions:
   - **Correctness** — logic errors, edge cases, error handling gaps, null/undefined paths
   - **Security** — injection risks, untrusted input, credential exposure, missing validation
   - **Performance** — unnecessary work, inefficient loops, N+1 queries, blocking I/O
   - **Maintainability** — duplication, naming, readability, consistency with project conventions
5. Output format per finding: `[High|Medium|Low] file:line — description`
6. If tests or build fail, your review must account for those failures.
7. Do not modify files or implement anything.
