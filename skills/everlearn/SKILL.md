---
name: everlearn
description: Captures durable learnings, decisions, research, workflows, source notes, customer signals, prompts, and weekly reviews into a local Markdown or Obsidian vault. Use when the user asks to save, remember, capture, log, learn from, add to Obsidian, update a knowledge base, run a learning review, or maintain a continual learning/second-brain workflow.
---

# Everlearn

Everlearn is a local-first knowledge capture workflow. It writes reusable notes to the user's configured Markdown vault.

## First Check

Look for `~/.everlearn/config`. If it exists, use `EVERLEARN_VAULT` and `EVERLEARN_PROFILE` from that file. If it does not exist, tell the user to run:

```bash
./scripts/setup.sh --profile general
```

If this skill was installed globally, scripts are usually available at:

- `~/.everlearn/bin/everlearn`
- `~/.codex/skills/everlearn/scripts/`
- `~/.claude/skills/everlearn/scripts/`
- `~/.agents/skills/everlearn/scripts/`

Claude Code installs may also expose `/everlearn` from `~/.claude/commands/everlearn.md`. Codex installs may expose an Everlearn prompt shortcut from `~/.codex/prompts/everlearn.md`, depending on the Codex version.

## Capture Rule

Write to the vault only when the user explicitly asks to capture/save/remember something, or when the user has opted into automatic Everlearn capture. At normal closeout, if durable learning was created, offer a short proposed capture instead of silently writing.

Do not capture secrets, credentials, cookies, private customer data, payment data, or confidential source text unless the user explicitly confirms the vault policy.

## Capture Types

| Type | Use For | Folder |
|---|---|---|
| `learning` | Reusable insight or lesson | `10 Learnings` |
| `decision` | Choice, rationale, tradeoffs | `20 Decisions` |
| `research` | Evidence, synthesis, sources | `30 Research` |
| `signal` | Customer, market, or demand signal | `30 Research/Customer Signals` |
| `workflow` | Repeatable process or SOP | `40 Workflows` |
| `prompt` | Reusable prompt or agent instruction | `40 Workflows/Prompts` |
| `source` | Source note or citation | `50 Sources` |
| `review` | Weekly/monthly synthesis | `60 Reviews` |
| `inbox` | Unsorted note | `00 Inbox` |

## Command Pattern

Prefer the installed command when available:

```bash
~/.everlearn/bin/everlearn capture --type learning --title "Short title" "The reusable learning."
```

For longer captures, write the body to a temporary file and pass:

```bash
~/.everlearn/bin/everlearn capture --type research --title "Source synthesis" --body-file /path/to/body.md
```

Run a weekly review:

```bash
~/.everlearn/bin/everlearn review
```

Verify setup:

```bash
~/.everlearn/bin/everlearn verify
```

## Nested SignalSweep Workflow

When the user is using Everlearn and asks to research a topic with SignalSweep, or asks to save SignalSweep research into Everlearn, run SignalSweep through Everlearn instead of changing SignalSweep's global defaults:

```bash
~/.everlearn/bin/everlearn signalsweep --topic "best starter bundles for cold plunge accessories"
```

This sets `SIGNALSWEEP_MEMORY_DIR` only for that one run, saves SignalSweep artifacts under `30 Research/SignalSweep`, and creates an Everlearn `research` note linking to the artifact.

To pass SignalSweep flags, put them after `--`:

```bash
~/.everlearn/bin/everlearn signalsweep --topic "standing desk customer complaints" -- --quick
```

If you have prepared SignalSweep targeting or a query plan as the host agent, pass those flags the same way, for example `-- --plan /tmp/signalsweep-plan.json --subreddits AmazonSeller`.

Use this nested workflow when SignalSweep is part of an Everlearn capture/research flow. Do not change the user's normal SignalSweep default save directory unless they explicitly ask.

## Note Quality

A good Everlearn note is short, source-aware, and reusable. Include:

- the learning or decision
- why it matters
- where to look next time
- links or file paths when available
- tags that will help retrieval

## Profiles

Use `references/profiles.md` for profile-specific examples. The profile changes examples and folder suggestions; the capture workflow stays the same.
