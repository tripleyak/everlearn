#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_source="$repo_root/skills/everlearn"
target="$HOME/.codex/skills/everlearn"

mkdir -p "$target"
(cd "$skill_source" && tar cf - .) | (cd "$target" && tar xf -)

printf "Installed Everlearn for Codex: %s\n" "$target"

