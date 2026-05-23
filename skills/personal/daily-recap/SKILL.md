---
metadata:
  internal: true
name: daily-recap
description: Retrospective pipeline for one or more past days — fetches calendar, scans Slack, email, GitHub, and Claude sessions, writes a raw journal entry, then ingests it into the wiki (daily/weekly/monthly/quarterly + goals). Use when the user says "recap yesterday", "process my journal", "I was on vacation catch me up", or runs /daily-recap with an optional date or range.
---
metadata:
  internal: true

# Daily Recap

Full retrospective pipeline: gather → draft → ingest. Covers yesterday by default; accepts a date or date range for catch-up.

## Before You Start

1. **Resolve config** — follow the Config Resolution Protocol in `llm-wiki/SKILL.md`. Walk up from CWD for `.env`, fall back to `~/.obsidian-wiki/config`, else prompt setup. This gives `OBSIDIAN_VAULT_PATH`, `JOURNAL_PATH`, `TEMPLATES_PATH`, and `DEEP_DIVE_GOALS_PATH`.
2. **Path contract** — all writes go under `OBSIDIAN_VAULT_PATH`. `JOURNAL_PATH` is **read-only**.

| What | Path | Access |
|---|---|---|
| Raw staging draft | `$OBSIDIAN_VAULT_PATH/_raw/journal/YYYY-MM-DD.md` | read+write (deleted after ingest) |
| Manual journal | `$JOURNAL_PATH/YYYY-MM-DD.md` | **read-only** |
| Ingested daily | `$OBSIDIAN_VAULT_PATH/journal/daily/YYYY-MM-DD.md` | write |
| Weekly rollup | `$OBSIDIAN_VAULT_PATH/journal/weekly/YYYY-WNN.md` | write |
| Monthly rollup | `$OBSIDIAN_VAULT_PATH/journal/monthly/YYYY-MM.md` | write |
| Quarterly rollup | `$OBSIDIAN_VAULT_PATH/journal/quarterly/YYYY-QN.md` | write |
| Deep Dive goals | `$DEEP_DIVE_GOALS_PATH` | read |
| Manifest | `$OBSIDIAN_VAULT_PATH/.manifest.json` | write |
| Log | `$OBSIDIAN_VAULT_PATH/log.md` | write |

---
metadata:
  internal: true

## Input parsing

Accepted forms:
- `/daily-recap` — last working day
- `/daily-recap 2026-05-15` — specific date
- `/daily-recap 2026-05-12 2026-05-15` — inclusive date range
- `/daily-recap 2026-05-12..2026-05-15` — same, dot-dot form

Derive the target date list before doing anything else. For ranges, process each date oldest → newest.

---
metadata:
  internal: true

## For each date in the target list

### Step 1 — Detect last working day (default only)

```python
from datetime import date, timedelta
d = date.today()
while d.weekday() >= 5:
    d -= timedelta(days=1)
if d == date.today():
    d -= timedelta(days=1)
    while d.weekday() >= 5:
        d -= timedelta(days=1)
```

### Step 2 — Check for existing staging draft

Check `$OBSIDIAN_VAULT_PATH/_raw/journal/YYYY-MM-DD.md`. If it exists, read it and use as base.

Extract from the seed (if written by `/daily-plan`):
- `### Meetings` table → pre-filled meeting stubs
- `### Focus` → context for goal mapping
- `### Pending / Slack` → cross-check against Slack scan
- `## Followups` → may be pre-populated with carry-forwards
- `## Notes` → anything the user added during the day — preserve verbatim

### Step 3 — Read manual journal (read-only)

Check `$JOURNAL_PATH/YYYY-MM-DD.md`. If it exists, read for additional context. **Never write to or delete this file.** Merge relevant content into the draft.

### Step 4 — Fetch calendar

Use your calendar tool for the target date (afterDateTime = date 00:00, beforeDateTime = date 23:59).

Extract: meeting title, start/end time (convert to user's local timezone), attendees.

Exclude: all-day events, personal blockers (no attendees).

### Step 5 — Scan Slack

Use your Slack search tool to find messages from/mentioning the user on the target date. Look for:
- Direct messages to the user
- Mentions of the user by name/handle
- Team channels where the user is involved
- Threads the user participated in

Summarise relevant activity. Include decisions, requests, or action items for the user.

### Step 5b — Scan Emails

Use your email search tool for emails received on the target date.

Look for:
- Emails requiring a reply or action
- Emails from external parties
- Threads where the user is CC'd and follow-up is expected
- Decisions communicated via email

Extract: sender, subject, gist, action item or decision. Skip newsletters, automated notifications, read receipts.

Merge relevant action items into Followups. Merge relevant decisions into Decisions & notes.

### Step 5c — Scan GitHub

Invoke the `github-check` skill with `--mode recap --date YYYY-MM-DD`.

Config is read from `$OBSIDIAN_VAULT_PATH/wiki/_meta/github-watch.md`.

Extract and merge into draft:
- Commits pushed → `## Worked on`
- PRs merged → `## Worked on`
- PRs reviewed → `## Worked on`
- Issues closed → `## Worked on`
- Review requests still open → `## Followups`
- CI failures on open PRs → `## Blockers`

Skip silently if nothing found. Do not duplicate items already captured from calendar or Slack.

### Step 5d — Scan Claude sessions

Invoke the `claude-sessions-check` skill with `--mode recap --date YYYY-MM-DD`.

Extract and merge into draft:
- Technical work (`✅`, `🔴`, `🟣`, `🔄`) → `## Worked on`
- Decisions (`⚖️`) → `## Decisions & notes`
- Discoveries (`🔵`) → `## Decisions & notes` if notable
- Unresolved threads → `## Followups`

Skip silently if nothing found.

### Step 6 — Map to journal sections

#### `## Worked on`
One bullet per meeting or activity:
```
- [Meeting/Activity Title] ([HH:MM–HH:MM]) — [1-line summary]
```

#### `## Blockers`
Blockers explicitly mentioned in any source. Skip if none.

#### `## Decisions & notes`
Relevant decisions only — skip noise.

#### `## Followups`
The user's own action items only. One bullet per item.

#### `## Links`
Leave empty.

#### `# Personal`
Leave empty.

### Step 7 — Link people

Every person name → `[[wiki/people/Full Name]]`. Check `$OBSIDIAN_VAULT_PATH/people/` for existing pages. Link even if no page exists — create a stub using `$TEMPLATES_PATH/people.md`. Never link the user themselves.

### Step 8 — Write and ingest

1. Write merged draft to `$OBSIDIAN_VAULT_PATH/_raw/journal/YYYY-MM-DD.md`
2. Promote to `$OBSIDIAN_VAULT_PATH/journal/daily/YYYY-MM-DD.md` — use `$TEMPLATES_PATH/journal-daily.md`; resolve goal labels from `$DEEP_DIVE_GOALS_PATH`
3. Update `$OBSIDIAN_VAULT_PATH/journal/weekly/YYYY-WNN.md`
4. Update `$OBSIDIAN_VAULT_PATH/journal/monthly/YYYY-MM.md`
5. Update `$OBSIDIAN_VAULT_PATH/journal/quarterly/YYYY-QN.md`
6. Delete `$OBSIDIAN_VAULT_PATH/_raw/journal/YYYY-MM-DD.md`
7. Update `$OBSIDIAN_VAULT_PATH/.manifest.json` and `$OBSIDIAN_VAULT_PATH/log.md`

---
metadata:
  internal: true

## Goal mapping

**Read goals dynamically from `$DEEP_DIVE_GOALS_PATH`.** Parse `## Goal N — Name` headings to extract current goal IDs. Build the `## Goal connections` section from whatever goals are defined — do not hardcode labels.

---
metadata:
  internal: true

## Multi-date ranges

Process each date independently in sequence. Summarise at the end: dates processed, total activities, total followups extracted.

---
metadata:
  internal: true

## Notes

- Slack scan is best-effort — skip silently if nothing relevant found
- Email scan is best-effort — skip newsletters, automated alerts; skip silently if nothing actionable
- Do not include other people's action items in Followups
- `JOURNAL_PATH` is read-only — never write, never delete files there
