# ai

My Claude Code setup — agents and skills for engineering work in energy infrastructure.

## What's here

| Directory | What it is |
|-----------|-----------|
| [`agents/engineering/`](agents/engineering/) | General-purpose Claude Code subagents for backend, frontend, data, devops, security, and incident response |
| [`agents/energy/`](agents/energy/) | Domain-specific agents for SCADA, Nordic ancillary markets, and asset dispatch optimisation |
| [`agents/productivity/`](agents/productivity/) | Writing agents for docs, ADRs, runbooks |
| [`skills/`](https://github.com/dominikbullo/skills) | Skills distributed separately via `npx skills` |

## Agents

Agents live in `~/.claude/agents/` and are invoked with `@agent-name` in Claude Code.

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

Purpose-built for energy infrastructure engineering. Useful if you work on BESS, wind, hydro, or Nordic power markets.

| Agent | Description |
|-------|-------------|
| [scada-engineer](agents/energy/scada-engineer.md) | IEC 61850, real-time PPC, grid integration, prequalification |
| [energy-market-analyst](agents/energy/energy-market-analyst.md) | FCR/mFRR/aFRR, Nord Pool, BRP obligations, bid optimisation |
| [optimization-engineer](agents/energy/optimization-engineer.md) | BESS/wind/hydro dispatch, MILP, rolling horizon, revenue stacking |

### Productivity

| Agent | Description |
|-------|-------------|
| [technical-writer](agents/productivity/technical-writer.md) | ADRs, RFCs, runbooks, API docs, onboarding guides |

## Install

### Agents

```bash
git clone https://github.com/dominikbullo/ai ~/ai
cd ~/ai && ./scripts/link-agents.sh
```

This symlinks all agents to `~/.claude/agents/`. Pull and re-run to update.

### Skills

Skills are distributed via [dominikbullo/skills](https://github.com/dominikbullo/skills):

```bash
npx skills@latest add dominikbullo/skills --global --all
```

## Stack

Python · FastAPI · Django · TypeScript · Vue.js · PostgreSQL · TimescaleDB · GCP · Kubernetes · Terraform

Domain: BESS · SCADA · EMS · IEC 61850 · FCR · mFRR · Nord Pool
