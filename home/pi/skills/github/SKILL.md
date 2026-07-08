---
name: github
description: Read-only GitHub operations via the `gh` CLI — always use this skill for any GitHub-related tasks (repos, issues, PRs, code, commits, releases, discussions, labels, etc.) instead of generic web tools.
---

## Setup

Verify `gh` is installed and authenticated:

```bash
gh auth status
```

If not authenticated, guide the user to run `gh auth login`. If not installed, guide the user to install from https://cli.github.com.

## Usage

**IMPORTANT**: This skill is READ-ONLY. Never create, modify, or delete any GitHub resources. Use `gh` with read-only subcommands only.

Append `-R owner/repo` when targeting a specific repository.

### Common Operations

```bash
gh repo view owner/repo               # Repository overview
gh repo list owner                    # List user/organization repos
gh search repos "topic:..."           # Search repositories

gh issue list -R owner/repo           # List issues
gh issue view <num> -R owner/repo     # View issue details
gh issue status -R owner/repo         # Issue summary

gh pr list -R owner/repo              # List pull requests
gh pr view <num> -R owner/repo        # View PR details
gh pr diff <num> -R owner/repo        # View PR diff
gh pr status -R owner/repo            # PR summary

gh label list -R owner/repo           # List repository labels
```

### Advanced Operations

For commands not covered above, use only read-only subcommands:

**Git data:** `gh api repos/o/r/commits`, `branches`, `tags`, `compare/main...branch`, `gh search commits`, `gh release list`, `gh release view`

**Label:** `gh api repos/o/r/labels/<name>` (single label details)

**Discussion:** `gh discussion list`, `gh discussion view`

**Search:** `gh search issues`, `gh search prs`, `gh search code`, `gh search commits`, `gh search repos`

**Raw API:** `gh api repos/o/r/<endpoint>` (GET only; use `--paginate` for multi-page results)

For any subcommand's flags, run `gh <subcommand> --help` or `gh api --help`. Use `--json <fields>` for structured output and `-q <jq>` to extract specific values.
