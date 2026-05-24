#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_source="$repo_root/skills/everlearn"

for target in "$HOME/.claude/skills/everlearn" "$HOME/.agents/skills/everlearn"; do
  mkdir -p "$target"
  (cd "$skill_source" && tar cf - .) | (cd "$target" && tar xf -)
  printf "Installed Everlearn for Claude-compatible skills: %s\n" "$target"
done

