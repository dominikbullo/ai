---
name: daily-plan
description: Morning planning brief — fetches today's calendar, pulls open followups from yesterday's journal, scans Slack and email, checks GitHub, surfaces Claude session threads, suggests focus areas mapped to goals, and writes a raw journal seed. Use when the user says "plan my day", "what's on today", "prepare me for the day", or runs /daily-plan.
---
metadata:
  internal: true

# Daily Plan

Morning planning brief. Shown in chat — writes a seed file to disk.

---
metadata:
  internal: true

## Before You Start

1. **Resolve config** — follow the Config Resolution Protocol in `llm-wiki/SKILL.md`. Walk up from CWD for `.env`, fall back to `~/.obsidian-wiki/config`, else prompt setup. This gives `OBSIDIAN_VAULT_PATH`, `JOURNAL_PATH`, `TEMPLATES_PATH`, and `DEEP_DIVE_GOALS_PATH`.
2. **Path contract** — read-only skill except for the raw seed write in Step 9.

| What | Path | Access |
|---|---|---|
| Ingested daily (yesterday) | `$OBSIDIAN_VAULT_PATH/journal/daily/YYYY-MM-DD.md` | read |
| Manual journal (yesterday/today) | `$JOURNAL_PATH/YYYY-MM-DD.md` | **read-only** |
| Deep Dive goals | `$DEEP_DIVE_GOALS_PATH` | read |
| Templates | `$TEMPLATES_PATH/` | read |
| Raw seed (today) | `$OBSIDIAN_VAULT_PATH/_raw/journal/YYYY-MM-DD.md` | **write** |

---
metadata:
  internal: true

## Step 1 — Detect today and last working day

```python
from datetime import date, timedelta
today = date.today()
prev = today - timedelta(days=1)
while prev.weekday() >= 5:
    prev -= timedelta(days=1)
```

---
metadata:
  internal: true

## Step 2 — Fetch today's calendar

Use your calendar tool (afterDateTime = today 00:00, beforeDateTime = today 23:59).

For each meeting extract: title, start/end time (convert to user's local timezone), attendees, location.

Classify:
- **Scheduled meetings** — has attendees or organizer other than the user
- **Focus blocks** — self-created blocks (Busy, no attendees)
- **All-day / personal** — skip

---
metadata:
  internal: true

## Step 3 — Pull open followups

Read `$OBSIDIAN_VAULT_PATH/journal/daily/YYYY-MM-DD.md` for the last working day.

Extract the `## Followups` section. Surface unchecked items as today's carry-forward.

If no ingested daily exists for yesterday, check `$OBSIDIAN_VAULT_PATH/_raw/journal/YYYY-MM-DD.md` as fallback. Mention if missing: "Yesterday's recap not found — run /daily-recap first."

---
metadata:
  internal: true

## Step 4 — Check manual journal (read-only)

Check `$JOURNAL_PATH/YYYY-MM-DD.md` for today or yesterday. If it exists, surface any work-relevant notes or agenda items. **Never write to or delete this file.**

---
metadata:
  internal: true

## Step 5 — Scan Slack

Use your Slack search tool for messages from the last 24 hours that:
- Mention the user directly
- Are direct messages awaiting a reply
- Are in team channels and require action

Summarise as pending items. Skip silently if nothing found.

---
metadata:
  internal: true

## Step 5b — Scan Emails

Use your email search tool for emails received today (and unread from yesterday).

Look for:
- Unread emails requiring a reply or action
- Emails from external parties
- Emails CC'd to the user where a response is expected
- Time-sensitive requests or deadlines

Extract: sender, subject, brief gist, required action. Skip newsletters, automated notifications, CI/CD alerts, and calendar invites already captured in Step 2.

Summarise as pending items. Skip silently if nothing actionable.

---
metadata:
  internal: true

## Step 5c — Check GitHub

Invoke the `github-check` skill with `--mode plan` for today.

Config is read from `$OBSIDIAN_VAULT_PATH/wiki/_meta/github-watch.md`.

Surface in the day brief:
- PRs where review is requested from you → **Pending / GitHub**
- Your open PRs with failing CI → treat as blocking items, elevate in focus suggestions
- Assigned issues with recent activity → surface if actionable

Skip silently if nothing actionable found.

---
metadata:
  internal: true

## Step 5d — Check Claude sessions

Invoke the `claude-sessions-check` skill with `--mode plan`.

Surfaces open threads and in-progress work from recent claude.ai and claude.ai/code sessions (yesterday + today so far). Add unresolved threads to the day brief under **Claude / open threads**.

Skip silently if no sessions found.

---
metadata:
  internal: true

## Step 6 — Suggest focus points

Read `$DEEP_DIVE_GOALS_PATH` to recall current goals.

Based on open followups + today's meetings + Slack + emails + GitHub + Claude sessions, suggest **1–3 focus points** for today. Format:
```
🎯 [Focus area] — [why it matters today / which goal it serves]
```

Prioritise:
1. Blocking items (things preventing others from proceeding)
2. High-impact items tied to current goals
3. Quick wins that can close open followups

---
metadata:
  internal: true

## Step 7 — Surface reminders

Check for time-sensitive items from:
- Followups with explicit deadlines
- Upcoming events mentioned in recent journals
- Calendar events later this week that need prep

---
metadata:
  internal: true

## Step 8 — Output day brief

Present in this structure (chat only, no file written):

```
# Plan — [Weekday], [Month Day]

## Today's meetings
| Time | Meeting | With |
|------|---------|------|
| HH:MM–HH:MM | [title] | [key attendees] |

## Open followups
- [item from yesterday]

## Slack / pending
- [item needing attention]
- ... (skip section if nothing)

## Emails / pending
- [sender] — [subject] — [required action]
- ... (skip section if nothing)

## GitHub / pending
- [repo] #N — [title] — [why it needs attention]
- ... (skip section if nothing)

## Claude / open threads
- [session context] — [what's unresolved / in-progress]
- ... (skip section if nothing)

## Focus today
🎯 [focus 1] — [goal/reason]
🎯 [focus 2] — [goal/reason]

## Reminders
- [deadline or event]
```

Keep it scannable. One line per item. No fluff.

---
metadata:
  internal: true

## Step 9 — Write raw seed

After presenting the brief, write a journal seed to `$OBSIDIAN_VAULT_PATH/_raw/journal/YYYY-MM-DD.md` (today's date).

Use the template at `$TEMPLATES_PATH/journal-seed.md` as base structure. Fill in:
- `### Meetings` table — real meetings only, skip all-day/personal
- `### Focus` — the 1–3 focus points from Step 6
- `### Pending / Slack` — items from Step 5. Skip section if nothing.
- `### Pending / Emails` — items from Step 5b. Skip section if nothing.
- `### Pending / GitHub` — items from Step 5c. Skip section if nothing.
- `### Claude / open threads` — items from Step 5d. Skip section if nothing.
- `## Followups` — carry-forward items from Step 3

If a seed file already exists for today, **do not overwrite** — leave it untouched and note it in chat.

---
metadata:
  internal: true

## Notes

- If today has no meetings, say so — the focus suggestion becomes more important
- Focus points should be opinionated — pick what matters, don't list everything
- `JOURNAL_PATH` is read-only — never write, never delete files there
- The raw seed written in Step 9 is the input for `/daily-recap` — run that at end of day
