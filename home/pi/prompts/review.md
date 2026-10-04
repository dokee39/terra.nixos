---
description: Review code for correctness, security, performance, and maintainability.
argument-hint: "<files, diff, or PR URL>"
---
Review: $ARGUMENTS

1. Read the relevant code.
2. Analyze the affected code as a whole, not just the changed lines, across these dimensions:
   - **Correctness** — logic errors, edge cases, error handling gaps, null/undefined paths
   - **Security** — injection risks, untrusted input, credential exposure, missing validation
   - **Performance** — unnecessary work, inefficient loops, N+1 queries, blocking I/O
   - **Maintainability** — duplication, naming, readability, consistency with project conventions
   - **Structural layering** — accreted conditions merging distinct cases, parameter bloat, switch arms grouping unrelated values
3. Output format per finding: `[High|Medium|Low] file:line — description`
4. If tests or build fail, your review must account for those failures.
5. Do not modify files except for normal test/build artifacts. Do not implement fixes.
