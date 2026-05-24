#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$script_dir/lib.sh"

load_config
failures=0

check_file() {
  label="$1"
  path="$2"
  if [ -f "$path" ]; then
    printf "OK: %s -> %s\n" "$label" "$path"
  else
    printf "MISSING: %s -> %s\n" "$label" "$path"
    failures=$((failures + 1))
  fi
}

check_dir() {
  label="$1"
  path="$2"
  if [ -d "$path" ]; then
    printf "OK: %s -> %s\n" "$label" "$path"
  else
    printf "MISSING: %s -> %s\n" "$label" "$path"
    failures=$((failures + 1))
  fi
}

printf "Everlearn profile: %s\n" "$EVERLEARN_PROFILE"
printf "Everlearn vault: %s\n\n" "$EVERLEARN_VAULT"

check_file "config" "$config_file"
check_dir "vault" "$EVERLEARN_VAULT"
check_dir "inbox" "$EVERLEARN_VAULT/00 Inbox"
check_dir "learnings" "$EVERLEARN_VAULT/10 Learnings"
check_dir "research" "$EVERLEARN_VAULT/30 Research"
check_file "command wrapper" "$everlearn_home/bin/everlearn"

printf "\nAgent skill installs:\n"
check_file "Claude Code skill" "$HOME/.claude/skills/everlearn/SKILL.md"
check_file "Claude Code /everlearn command" "$HOME/.claude/commands/everlearn.md"
check_file "Codex skill" "$HOME/.codex/skills/everlearn/SKILL.md"
check_file "Codex Everlearn prompt" "$HOME/.codex/prompts/everlearn.md"
check_file "Shared agents skill" "$HOME/.agents/skills/everlearn/SKILL.md"

if [ "$failures" -gt 0 ]; then
  printf "\nEverlearn verification failed with %s missing item(s).\n" "$failures" >&2
  exit 1
fi

printf "\nEverlearn verification passed.\n"
