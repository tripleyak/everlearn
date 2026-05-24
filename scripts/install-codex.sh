#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_source="$repo_root/skills/everlearn"
prompt_source="$repo_root/prompts/everlearn.md"
target="$HOME/.codex/skills/everlearn"

mkdir -p "$target"
(cd "$skill_source" && tar cf - .) | (cd "$target" && tar xf -)

printf "Installed Everlearn for Codex: %s\n" "$target"

if [ -f "$prompt_source" ]; then
  mkdir -p "$HOME/.codex/prompts"
  cp "$prompt_source" "$HOME/.codex/prompts/everlearn.md"
  printf "Installed Codex prompt shortcut: everlearn\n"
fi
