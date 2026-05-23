---
metadata:
  internal: true
name: github-check
description: Scan watched GitHub repositories for PRs, review requests, CI status, commits, and issues. Reads repo list from wiki/_meta/github-watch.md. Usable standalone (/github-check) or called by daily-plan/daily-recap. Accepts --date, --range, --all, --mode flags.
---
metadata:
  internal: true

# GitHub Check

Scan GitHub repositories for activity relevant to Dominik. Reads config from `wiki/_meta/github-watch.md`.

---
metadata:
  internal: true

## Before You Start

1. **Resolve vault path** — follow Config Resolution Protocol in `llm-wiki/SKILL.md`. Need `OBSIDIAN_VAULT_PATH`.
2. **Read config** — read `$OBSIDIAN_VAULT_PATH/wiki/_meta/github-watch.md`. Extract:
   - `gh_user` (default: `dominikbullo`)
   - `org` (default: `ingridcapacity`)
   - `scan_all` (`true`/`false`)
   - Watched Repos list (bullet lines under `## Watched Repos`)
3. **Parse flags** from invocation args:
   - `--date YYYY-MM-DD` — target date (default: today)
   - `--range YYYY-MM-DD YYYY-MM-DD` — inclusive date range
   - `--all` — override `scan_all`, scan entire org
   - `--mode plan|recap|standalone` — output format (default: `standalone`)

---
metadata:
  internal: true

## Step 1 — Resolve repo list

If `scan_all: true` OR `--all` flag:
```bash
gh repo list ingridcapacity --limit 100 --json nameWithOwner --jq '.[].nameWithOwner'
```
Use the resulting list as `REPOS`.

Otherwise use the bullet list from `## Watched Repos` in the config file as `REPOS`.

---
metadata:
  internal: true

## Step 2 — Fetch data (parallel where possible)

Run these `gh` CLI commands. Batch by category — do not make one call per repo serially; group all repos per check type.

### Plan / standalone mode checks

**Open PRs authored by you:**
```bash
gh pr list --author @me --repo <repo> --state open --json number,title,url,createdAt,statusCheckRollup
```
Run for each repo in `REPOS`.

**PRs with review requested from you:**
```bash
gh search prs --review-requested=@me --repo ingridcapacity/<repo> --state open --json number,title,url,repository,author,createdAt
```
Or use the org-wide search:
```bash
gh pr list --search "review-requested:@me org:ingridcapacity" --json number,title,url,repository,author,createdAt --limit 50
```

**Issues assigned to you (open):**
```bash
gh issue list --assignee @me --repo <repo> --state open --json number,title,url,updatedAt
```
Run for each repo — skip repos where this returns empty.

### Recap mode checks (requires `--date` or `--range`)

**Commits pushed on date:**
```bash
gh api "repos/<repo>/commits?author=dominikbullo&since=<DATE>T00:00:00Z&until=<DATE>T23:59:59Z" --jq '[.[] | {sha: .sha[:7], message: .commit.message | split("\n")[0], url: .html_url}]'
```

**PRs merged on date:**
```bash
gh pr list --repo <repo> --state merged --search "merged:<DATE>" --json number,title,url,mergedAt
```

**PRs reviewed by you on date** (org-wide search is more efficient):
```bash
gh search prs --reviewed-by=@me --merged-after=<DATE> --merged-before=<DATE> --json number,title,url,repository
```

**Issues closed on date:**
```bash
gh issue list --repo <repo> --state closed --search "closed:<DATE>" --assignee @me --json number,title,url,closedAt
```

---
metadata:
  internal: true

## Step 3 — CI status for open PRs

For each open PR you authored, check CI:
```bash
gh pr checks <number> --repo <repo> --json name,state,conclusion
```

Classify:
- **✅ passing** — all checks `conclusion: success` or `skipped`
- **❌ failing** — any check `conclusion: failure` or `state: error`
- **⏳ pending** — any check `state: in_progress` or `queued`
- **○ no CI** — empty checks list

---
metadata:
  internal: true

## Step 4 — Format output

### Standalone / plan mode output

```
## GitHub

### PRs needing your review
- [org/repo] #N — Title (by Author, N days old)
- ... (skip section header if empty)

### Your open PRs
- [org/repo] #N — Title — ✅ / ❌ / ⏳ / ○
- ... (skip section header if empty)

### Assigned issues (open)
- [org/repo] #N — Title (updated N days ago)
- ... (skip section header if empty)
```

If all sections empty: output `## GitHub — nothing pending`.

### Recap mode output

```
## GitHub activity

### Commits & pushes
- org/repo — N commits
  - abc1234: Commit message
  - ...
(skip if no commits)

### PRs merged
- [org/repo] #N — Title
(skip if none)

### PRs reviewed
- [org/repo] #N — Title (approved / changes-requested / commented)
(skip if none)

### Issues closed
- [org/repo] #N — Title
(skip if none)
```

If all sections empty: output `## GitHub activity — nothing found for <date>`.

---
metadata:
  internal: true

## Notes

- `gh` CLI is pre-authenticated; no login step needed
- Skip archived repos silently (check `isArchived` field if using `gh repo list`)
- For date math use ISO 8601 format: `YYYY-MM-DDT00:00:00Z`
- If `gh` is not installed or auth fails, surface the error clearly: "GitHub check failed: `<error>` — ensure `gh auth status` passes"
- Do not include other people's action items — Dominik only
- Repo name in output: short form (`delivery-api`) not full URL, unless the output section has repos from multiple orgs
