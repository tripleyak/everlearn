#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_source="$repo_root/skills/everlearn"
command_source="$repo_root/skills/everlearn/commands/everlearn.md"
prompt_source="$repo_root/prompts/everlearn.md"
target="$HOME/.codex/skills/everlearn"

mkdir -p "$target"
(cd "$skill_source" && tar cf - .) | (cd "$target" && tar xf -)

printf "Installed Everlearn for Codex: %s\n" "$target"

if [ -f "$command_source" ]; then
  mkdir -p "$HOME/.codex/commands"
  cp "$command_source" "$HOME/.codex/commands/everlearn.md"
  printf "Installed Codex slash command: /everlearn\n"
fi

if [ -f "$prompt_source" ]; then
  mkdir -p "$HOME/.codex/prompts"
  cp "$prompt_source" "$HOME/.codex/prompts/everlearn.md"
  printf "Installed Codex prompt shortcut: everlearn\n"
fi
