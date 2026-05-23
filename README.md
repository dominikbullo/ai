# ai

My Claude Code setup — agents and skills for engineering work in energy infrastructure.

## Install

```bash
# Clone and link agents to ~/.claude/agents/
git clone https://github.com/dominikbullo/ai ~/ai && ~/ai/scripts/link-agents.sh

# Install skills to ~/.claude/skills/
npx skills@latest add dominikbullo/ai --global --all
```

Pull and re-run the scripts to update.

---

## Agents

Subagents invoked with `@agent-name` in Claude Code. Definitions live in `agents/`.

### Engineering

| Agent | Description |
|-------|-------------|
| [backend-architect](agents/engineering/backend-architect.md) | Python/FastAPI, async patterns, API and database design |
| [frontend-developer](agents/engineering/frontend-developer.md) | Vue.js/TypeScript, composables, component architecture |
| [data-engineer](agents/engineering/data-engineer.md) | TimescaleDB, time-series pipelines, PostgreSQL optimisation |
| [devops-engineer](agents/engineering/devops-engineer.md) | Kubernetes, Terraform, GCP, CI/CD |
| [code-reviewer](agents/engineering/code-reviewer.md) | Correctness, security, and maintainability — not style |
| [incident-commander](agents/engineering/incident-commander.md) | Structure for active incidents, postmortem facilitation |
| [security-reviewer](agents/engineering/security-reviewer.md) | OWASP Top 10, auth/authz, injection, threat modelling |

### Energy

Purpose-built for energy infrastructure. Useful if you work on BESS, wind, hydro, or Nordic power markets.

| Agent | Description |
|-------|-------------|
| [scada-engineer](agents/energy/scada-engineer.md) | IEC 61850, real-time PPC, grid integration, prequalification |
| [energy-market-analyst](agents/energy/energy-market-analyst.md) | FCR/mFRR/aFRR, Nord Pool, BRP obligations, bid optimisation |
| [optimization-engineer](agents/energy/optimization-engineer.md) | BESS/wind/hydro dispatch, MILP, rolling horizon, revenue stacking |

### Productivity

| Agent | Description |
|-------|-------------|
| [technical-writer](agents/productivity/technical-writer.md) | ADRs, RFCs, runbooks, API docs, onboarding guides |

---

## Skills

Invoked with `/skill-name` in Claude Code. Definitions live in `skills/`.

| Skill | Description |
|-------|-------------|
| [daily-plan](skills/personal/daily-plan/SKILL.md) | Morning planning brief — calendar, followups, Slack, focus areas |
| [daily-recap](skills/personal/daily-recap/SKILL.md) | Retrospective pipeline — journal entry + wiki ingestion |
| [github-check](skills/personal/github-check/SKILL.md) | Scan watched repos for PRs, reviews, CI status, issues |
| [claude-sessions-check](skills/personal/claude-sessions-check/SKILL.md) | Surface Claude session activity for a date or range |

---

## Stack

Python · FastAPI · Django · TypeScript · Vue.js · PostgreSQL · TimescaleDB · GCP · Kubernetes · Terraform  
BESS · SCADA · EMS · IEC 61850 · FCR · mFRR · Nord Pool
