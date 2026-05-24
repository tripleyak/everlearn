#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$script_dir/lib.sh"

load_config
ensure_vault_folders

week_id="$(date +%Y-W%V)"
today="$(date +%Y-%m-%d)"
target_dir="$EVERLEARN_VAULT/60 Reviews"
mkdir -p "$target_dir"
review_path="$target_dir/$today-everlearn-weekly-review.md"

{
  printf -- "---\n"
  printf 'title: "Everlearn Weekly Review %s"\n' "$week_id"
  printf "type: review\n"
  printf "profile: %s\n" "$EVERLEARN_PROFILE"
  printf "created: %s\n" "$(date +%Y-%m-%dT%H:%M:%S%z)"
  printf "tags:\n"
  printf "  - everlearn\n"
  printf "  - review\n"
  printf "  - %s\n" "$EVERLEARN_PROFILE"
  printf -- "---\n\n"
  printf "# Everlearn Weekly Review %s\n\n" "$week_id"
  printf "## Recent Captures\n\n"
  recent_count=0
  while IFS= read -r note; do
    rel="${note#$EVERLEARN_VAULT/}"
    printf -- "- [[%s]]\n" "${rel%.md}"
    recent_count=$((recent_count + 1))
  done <<EOF
$(find "$EVERLEARN_VAULT" -type f -name "*.md" -mtime -7 ! -path "$target_dir/*" | sort | head -50)
EOF
  if [ "$recent_count" -eq 0 ]; then
    printf -- "- No captures found from the last 7 days.\n"
  fi
  printf "\n## Useful Learnings\n\n- \n\n"
  printf "## Decisions To Preserve\n\n- \n\n"
  printf "## Patterns\n\n- \n\n"
  printf "## Next Experiments\n\n- \n\n"
  printf "## Promote To Rules Or Skills\n\n- \n"
} > "$review_path"

printf "Everlearn review created: %s\n" "$review_path"

