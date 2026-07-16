---
name: github
description: Read-only GitHub operations via the `gh` CLI — always use this skill for any GitHub-related tasks (repos, issues, PRs, code, commits, releases, discussions, labels, etc.) instead of generic web tools.
---

## Setup

`gh` must be installed and authenticated. If a command fails with auth error, run `gh auth status` and report the result to the user.

## Usage

**IMPORTANT**: This skill is READ-ONLY. Never create, modify, or delete any GitHub resources. Use `gh` with read-only subcommands only.

Append `-R owner/repo` when targeting a specific repository.

### Common Operations

```bash
gh repo view owner/repo               # Repository overview

gh api repos/o/r/contents/<path>?ref=<ref> -q '.content' | base64 -d  # View file at branch/tag
gh api repos/o/r/contents/<dir> -q '.[] | "\(.type): \(.name)"'       # List directory

gh release list -R owner/repo         # List releases
gh label list -R owner/repo           # List labels

gh search repos "query"                                # Search repositories
gh search code "query" -R owner/repo                   # Search code
gh search issues "query" -R owner/repo --state=open    # Search issues or PRs

gh issue view <num> -R owner/repo -c                   # View issue details
gh pr view <num> -R owner/repo -c                      # View PR details
gh pr diff <num> -R owner/repo                         # View PR diff
```

### Advanced Operations

Other read-only subcommands available: `commits`, `branches`, `tags`, `compare`, `discussion`, `secret`, `variable`, `ruleset`, `attestation`, and more. Run `gh <subcommand> --help` for flags and usage.

Common patterns:
- `--json <fields>` for machine-readable output
- `-q <jq>` to extract specific values from JSON
- `--paginate` for multi-page results via `gh api`
- `-R owner/repo` targets any repository

For full git access (blame, log, grep, large files), clone to `/tmp`:
```
gh repo clone owner/repo /tmp/repo-name -- --depth=1
```

