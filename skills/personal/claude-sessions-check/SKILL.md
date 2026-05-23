---
metadata:
  internal: true
name: claude-sessions-check
description: Surface Claude AI session activity (claude.ai + claude.ai/code) for a given date or date range. Queries claude-mem MCP timeline for automated sources; prompts for manual web/mobile input. Used by daily-plan (surface open threads) and daily-recap (capture what was worked on). Call directly with /claude-sessions-check [--date YYYY-MM-DD] [--range ...] [--mode plan|recap|standalone].
---
metadata:
  internal: true

# Claude Sessions Check

Surface what was worked on across Claude sessions for a given date.

| Source | Access |
|---|---|
| claude.ai/code CLI | ✅ claude-mem MCP (automated) |
| Claude Desktop app | ✅ claude-mem MCP (automated) |
| claude.ai web | ⚠️ manual input (no API) |
| claude.ai mobile | ⚠️ manual input (no API) |

---
metadata:
  internal: true

## Inputs (all optional)

- `--date YYYY-MM-DD` — target date (default: yesterday in recap mode, today in plan mode)
- `--range YYYY-MM-DD YYYY-MM-DD` — inclusive range (for catch-up)
- `--mode plan|recap|standalone` — controls output shape (default: `standalone`)

---
metadata:
  internal: true

## Step 1 — Query claude-mem timeline

Use the `timeline` MCP tool from the `claude-mem` plugin. Request observations for the target date (or range).

Each observation has:
- An ID (numeric or session-scoped like `S18`)
- A timestamp
- A type tag: `✅ change`, `🔵 discovery`, `⚖️ decision`, `🔴 bugfix`, `🟣 feature`, `🔄 refactor`, `🎯 session`
- A title/summary

Filter to the target date. Group by session (observations sharing a session prefix belong together).

If the timeline returns nothing for the target date, note it — still proceed to Step 2.

---
metadata:
  internal: true

## Step 2 — Fallback: scan local JSONL (if claude-mem returned nothing)

Covers sessions that ran but aren't yet in claude-mem (e.g. very recent or untracked sessions).

### Source 1: Claude Code CLI (`~/.claude/`)
```bash
find ~/.claude/projects -name "*.jsonl" -not -path "*/subagents/*"
```
Filter to files with `timestamp` entries matching the target date.

### Source 2: Claude Desktop app
```bash
find ~/Library/Application\ Support/Claude/local-agent-mode-sessions -name "*.jsonl" -path "*/.claude/projects/*"
```
Filter to files modified on target date.

### Extracting from JSONL

- Skip `type: "progress"` and `type: "file-history-snapshot"` entries
- From assistant messages: extract `text` content blocks only (skip `thinking` and `tool_use`)
- `cwd` field gives project context
- Derive session topic from first user message + assistant response
- Summarise each session in 1–2 sentences. Do not copy verbatim text.

---
metadata:
  internal: true

## Step 3 — Prompt for web / mobile input

**Always do this step**, regardless of what automated sources returned.

Output this prompt to the user:

```
Any claude.ai web or mobile sessions worth capturing for [DATE]?
Paste a quick summary (one line per topic is enough), or say "skip" / "none".
```

Wait for a response before proceeding to Step 4.

If the user says "skip", "none", "no", or similar → proceed immediately.

If the user pastes content → treat each line/paragraph as a session summary. Extract:
- What was discussed / decided / worked on
- Any action items or follow-ups mentioned

**In plan mode only:** also prompt for *today so far* in addition to yesterday.

---
metadata:
  internal: true

## Step 4 — Merge and format output

Combine automated (claude-mem + JSONL) and manual (web/mobile) results.

### Plan mode output

```
## Claude sessions

- [project/topic] — [1-line summary] — automated / web / mobile
  → Still open / resolved
- ...

### Open threads
- [anything unresolved that may continue today]
```

Skip section entirely if nothing found and user said skip.

### Recap mode output

```
## Claude sessions

- [Session topic] — [what was done / discovered / decided]  _(automated)_
  - 🔵 [discovery]
  - ✅ [change]
  - ⚖️ [decision]
  - 🔴 [bugfix]
- [Topic from web/mobile] — [summary]  _(web/mobile)_
```

Map to journal sections:
- `✅` / `🔴` / `🟣` / `🔄` → `## Worked on`
- `⚖️` → `## Decisions & notes`
- `🔵` → `## Decisions & notes` (platform-relevant only)
- Unresolved / open → `## Followups`

### Standalone output

Full summary, all types shown, grouped by session. Label source: automated / web / mobile.

---
metadata:
  internal: true

## Notes

- Do not include `thinking` block contents — internal reasoning, not work product
- Skip sessions that are purely personal or unrelated to Ingrid work
- Skip short sessions (< 3 exchanges) with nothing notable
- Web/mobile summaries: trust what the user pastes — don't second-guess or ask for clarification unless genuinely ambiguous
