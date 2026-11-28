---
name: github
description: Read-only GitHub operations via the `gh` CLI (repos, issues, PRs, code, commits, releases, discussions, labels, etc.). Prefer this over generic web tools for GitHub tasks.
---

## Setup

`gh` must be installed and authenticated. If a command fails with auth error, run `gh auth status` and report the result to the user.

## Usage

**IMPORTANT**: This skill is READ-ONLY. Never create, modify, or delete any GitHub resources. Use `gh` with read-only subcommands only; with `gh api`, pass `-X GET` when using `-f`/`-F` query parameters (otherwise it defaults to `POST`).

When targeting a repository, use `-R owner/repo` where supported; for `gh api` REST requests, include it in the endpoint.

### Common Operations

```bash
gh repo view owner/repo                                # Repository overview
gh repo read-file <path> -R owner/repo [--ref <ref>]   # View file
gh repo read-dir [<dir>] -R owner/repo [--ref <ref>]   # List directory

gh release list -R owner/repo                          # List releases
gh label list -R owner/repo                            # List labels

gh search repos "query"                                # Search repositories
gh search code "query" -R owner/repo                   # Search code
gh search commits "query" -R owner/repo                # Search commits
gh search issues "query" -R owner/repo --state=open --include-prs  # Search issues and PRs

gh issue view <num> -R owner/repo                      # View issue body (-c prints comments only in non-TTY)
gh pr view <num> -R owner/repo                         # View PR body (--json title,body,comments for all)
gh pr diff <num> -R owner/repo                         # View PR diff
```

### Advanced Operations

Use `gh api` for branch commit history, branches, tags, comparisons, inline PR review comments, and GraphQL. Other command groups include `discussion`, `run`, `workflow`, `secret`, `variable`, `ruleset`, and `attestation`. Run `gh <command> --help` to find read-only subcommands.

Common patterns:
- `--json <fields>` for machine-readable output
- `-q <jq>` to extract specific values from JSON
- `--paginate --slurp` for multi-page JSON results via `gh api`

For local source inspection, clone to `/tmp`:
```bash
gh repo clone owner/repo /tmp/repo-name -- --depth=1
```

Shallow clones omit earlier history. Fetch additional history as needed for `log` or `blame`.
