---
description: Capture learnings, decisions, research, customer signals, prompts, workflows, and reviews into Everlearn
argument-hint: "[capture|signal|decision|research|signalsweep|review|verify] [details]"
---

Use the everlearn skill for this command.

# Everlearn Command

Parse `$ARGUMENTS` and route the request.

## If No Arguments

Show this short menu and ask which action to run:

```text
Everlearn

1. Capture a learning
2. Capture a customer signal
3. Capture a decision
4. Capture research
5. Run SignalSweep into Everlearn
6. Run weekly review
7. Verify setup
```

## Routes

| Input | Action |
|---|---|
| `verify` | Run `~/.everlearn/bin/everlearn verify` |
| `review` or `weekly-review` | Run `~/.everlearn/bin/everlearn review` |
| `signalsweep <topic>` or `research signalsweep <topic>` | Run `~/.everlearn/bin/everlearn signalsweep --topic "<topic>"` |
| `signal <text>` | Capture as `--type signal` |
| `decision <text>` | Capture as `--type decision` |
| `research <text>` | Capture as `--type research` |
| `workflow <text>` | Capture as `--type workflow` |
| `prompt <text>` | Capture as `--type prompt` |
| Anything else | Treat as a natural-language Everlearn capture request |

## Capture Behavior

- Use `~/.everlearn/bin/everlearn capture` when the request can be captured directly.
- For longer notes, write the body to a temporary Markdown file and pass `--body-file`.
- Choose a short, specific title.
- Do not capture secrets, credentials, cookies, payment data, or private customer data.
- After capture, report the vault path created.

## SignalSweep Behavior

When SignalSweep is requested as part of Everlearn, use:

```bash
~/.everlearn/bin/everlearn signalsweep --topic "topic"
```

Pass extra SignalSweep flags after `--` only when the user provides them or the current workflow needs them.

Do not change SignalSweep's global default save directory.
