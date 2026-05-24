#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
exec "$repo_root/skills/everlearn/scripts/capture-signalsweep.sh" "$@"

