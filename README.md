# Everlearn

Everlearn is a local-first continual learning engine for Claude Code, Codex, and other AI agents.

It gives agents a simple, repeatable way to save durable learnings, decisions, research, customer signals, workflows, prompts, and weekly reviews into a Markdown vault you own. The vault works well in Obsidian, but it is just folders and `.md` files.

## Workshop Quick Start

Use this path during the AI for Ecommerce workshop:

Fast install/update:

```bash
curl -fsSL https://raw.githubusercontent.com/tripleyak/everlearn/v2026-05-27-workshop/scripts/install.sh | bash -s -- --ref v2026-05-27-workshop --profile ecommerce
```

ZIP install:

```bash
cd ~/Downloads
unzip everlearn-workshop.zip
cd everlearn
./scripts/setup.sh --profile ecommerce
```

Then test one capture:

```bash
~/.everlearn/bin/everlearn capture \
  --type signal \
  --title "Customer asked for a cheaper bundle" \
  "A shopper wanted a lower-priced starter bundle before buying the full kit."
```

Open `~/Everlearn Vault` in Obsidian to see the note.

## What It Installs

`./scripts/setup.sh` creates:

- `~/Everlearn Vault` by default
- `~/.everlearn/config`
- `~/.everlearn/bin/everlearn`
- `~/.claude/skills/everlearn`
- `~/.claude/commands/everlearn.md`
- `~/.codex/skills/everlearn`
- `~/.codex/skills/everlearn/commands/everlearn.md`
- `~/.codex/commands/everlearn.md`
- `~/.codex/prompts/everlearn.md`
- `~/.agents/skills/everlearn`

The extra `~/.agents/skills` install keeps the skill visible in shared skill runtimes that both Claude Code and Codex can read.

The curl installer stores the downloaded source at `~/.everlearn/source` and can be rerun later to update the local skill and command files.

## Core Commands

```bash
~/.everlearn/bin/everlearn capture --type learning --title "What worked" "The short version of the learning."
~/.everlearn/bin/everlearn capture --type decision --title "Use Shopify bundle test" "Decision and rationale."
~/.everlearn/bin/everlearn capture --type research --title "Competitor review notes" "Summary and source links."
~/.everlearn/bin/everlearn capture --type workflow --title "Weekly ad review flow" "Steps that should be reused."
~/.everlearn/bin/everlearn signalsweep --topic "standing desk customer complaints" -- --quick
~/.everlearn/bin/everlearn review
~/.everlearn/bin/everlearn verify
```

In Claude Code, restart after setup and use:

```text
/everlearn signal Customers keep asking whether the starter bundle includes replacement filters.
```

In Codex, restart after setup and use:

```text
/everlearn signal Customers keep asking whether the starter bundle includes replacement filters.
```

Plain English also works:

```text
Use Everlearn to capture the reusable learning from this session.
```

## Profiles

Everlearn is general. Profiles tune the default examples and folder suggestions:

- `general`: everyday learnings, decisions, research, workflows
- `ecommerce`: customer signals, product ideas, marketplace research, ad learnings
- `coding`: repo learnings, architecture decisions, debugging notes, reusable commands
- `research`: source notes, evidence, claims, synthesis
- `operations`: SOPs, process decisions, recurring reviews

The workshop uses `ecommerce`, but attendees can switch later:

```bash
./scripts/setup.sh --profile general
```

## Capture Philosophy

Everlearn starts explicit by design. It does not scrape private transcripts, index your whole computer, or send notes to a cloud service.

Good captures are short, reusable, and specific:

- What changed your mind?
- What should you reuse next time?
- What source or evidence supports it?
- Where should the agent look first next time?

## SignalSweep Integration

Everlearn can run SignalSweep as a nested research step without changing SignalSweep's default save directory.

```bash
~/.everlearn/bin/everlearn signalsweep \
  --topic "customer complaints about cold plunge accessories" \
  -- --quick
```

That command:

- scopes `SIGNALSWEEP_MEMORY_DIR` to this one run only
- saves raw SignalSweep artifacts to `~/Everlearn Vault/30 Research/SignalSweep`
- creates an Everlearn `research` note that links to the saved artifact

SignalSweep's normal default can remain your main Obsidian KB or any other directory you already use.

## Repository Layout

```text
everlearn/
├── INSTALL.md
├── README.md
├── examples/
├── profiles/
├── scripts/
└── skills/
    └── everlearn/
        ├── SKILL.md
        ├── examples/
        ├── references/
        └── scripts/
```

## Safety

Everlearn is meant for local knowledge capture, not secret storage. Do not capture API keys, cookies, passwords, payment data, customer private data, or confidential material unless you have a clear reason and a safe vault policy.
