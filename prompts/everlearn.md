---
description: Capture learnings, decisions, research, customer signals, prompts, workflows, and reviews into Everlearn
argument-hint: "[capture|signal|decision|research|signalsweep|review|verify] [details]"
---

Use the $everlearn skill for this command and follow its instructions.

# Everlearn

## Request

<everlearn_request>
#$ARGUMENTS
</everlearn_request>

## Routing

- If the request is empty, show a concise menu for capture, SignalSweep research, review, and verify.
- If the request is `verify`, run `~/.everlearn/bin/everlearn verify`.
- If the request is `review` or `weekly-review`, run `~/.everlearn/bin/everlearn review`.
- If the request starts with `signalsweep`, run SignalSweep through Everlearn with `~/.everlearn/bin/everlearn signalsweep --topic "<topic>"`.
- If the request asks to capture or save a learning, decision, research note, customer signal, workflow, or prompt, use `~/.everlearn/bin/everlearn capture` with the best matching type.
- If the request is ambiguous, ask one short clarifying question.

## Rules

- Keep captures short, source-aware, and reusable.
- Use a temporary body file for long notes.
- Do not capture secrets, credentials, cookies, payment data, or private customer data.
- Report the created vault path.
