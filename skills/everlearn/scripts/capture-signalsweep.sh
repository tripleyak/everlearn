#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage:
  everlearn signalsweep --topic "Topic to research" [--title "Note title"] [--type research] [-- --mock --quick]
  everlearn signalsweep "Topic to research" -- --mock

Runs SignalSweep with its save directory scoped to the Everlearn vault, then
creates an Everlearn note linking to the saved SignalSweep artifact.

Use -- after the topic to pass flags directly to SignalSweep.
USAGE
}

load_config

topic=""
title=""
note_type="research"
profile="$EVERLEARN_PROFILE"
extra_tags="signalsweep"
signal_dir="$EVERLEARN_VAULT/30 Research/SignalSweep"
signalsweep_dir="${SIGNALSWEEP_SKILL_DIR:-}"
forward_args=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --topic)
      topic="${2:-}"
      shift 2
      ;;
    --title)
      title="${2:-}"
      shift 2
      ;;
    --type)
      note_type="${2:-}"
      shift 2
      ;;
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --tags)
      extra_tags="signalsweep,${2:-}"
      shift 2
      ;;
    --signalsweep-dir)
      signalsweep_dir="${2:-}"
      shift 2
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        forward_args+=("$1")
        shift
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      forward_args+=("$1")
      shift
      ;;
    *)
      if [ -z "$topic" ]; then
        topic="$1"
      else
        forward_args+=("$1")
      fi
      shift
      ;;
  esac
done

if [ -z "$topic" ]; then
  printf "Missing required topic.\n\n" >&2
  usage >&2
  exit 2
fi

case "$note_type" in
  research|signal|source|learning) ;;
  *)
    printf "Unsupported Everlearn note type for SignalSweep: %s\n" "$note_type" >&2
    exit 2
    ;;
esac

resolve_signalsweep_dir() {
  if [ -n "$signalsweep_dir" ] && [ -f "$signalsweep_dir/scripts/signalsweep.py" ]; then
    printf "%s" "$signalsweep_dir"
    return 0
  fi

  for candidate in \
    "$HOME/.codex/skills/signalsweep" \
    "$HOME/.claude/skills/signalsweep" \
    "$HOME/.agents/skills/signalsweep" \
    "$HOME/Projects/signalsweep"; do
    if [ -f "$candidate/scripts/signalsweep.py" ]; then
      printf "%s" "$candidate"
      return 0
    fi
  done

  return 1
}

resolve_python() {
  for py in python3.14 python3.13 python3.12 python3; do
    command -v "$py" >/dev/null 2>&1 || continue
    "$py" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)' >/dev/null 2>&1 || continue
    printf "%s" "$py"
    return 0
  done
  return 1
}

if ! signalsweep_dir="$(resolve_signalsweep_dir)"; then
  printf "SignalSweep was not found. Install it in ~/.codex/skills/signalsweep, ~/.claude/skills/signalsweep, ~/.agents/skills/signalsweep, or set SIGNALSWEEP_SKILL_DIR.\n" >&2
  exit 1
fi

if ! signalsweep_python="$(resolve_python)"; then
  printf "SignalSweep requires Python 3.12 or newer.\n" >&2
  exit 1
fi

ensure_vault_folders
mkdir -p "$signal_dir"

stdout_file="$(mktemp "${TMPDIR:-/tmp}/everlearn-signalsweep-stdout.XXXXXX")"
stderr_file="$(mktemp "${TMPDIR:-/tmp}/everlearn-signalsweep-stderr.XXXXXX")"
body_file="$(mktemp "${TMPDIR:-/tmp}/everlearn-signalsweep-body.XXXXXX")"
plan_file=""
cleanup() {
  rm -f "$stdout_file" "$stderr_file" "$body_file"
  if [ -n "$plan_file" ]; then
    rm -f "$plan_file"
  fi
}
trap cleanup EXIT

has_plan=0
for arg in "${forward_args[@]}"; do
  case "$arg" in
    --plan|--plan=*|--competitors-plan|--competitors-plan=*)
      has_plan=1
      ;;
  esac
done

if [ "$has_plan" -eq 0 ]; then
  plan_file="$(mktemp "${TMPDIR:-/tmp}/everlearn-signalsweep-plan.XXXXXX")"
  "$signalsweep_python" - "$topic" > "$plan_file" <<'PY'
import json
import sys

topic = sys.argv[1]
plan = {
    "intent": "product",
    "freshness_mode": "balanced_recent",
    "cluster_mode": "market",
    "source_weights": {},
    "subqueries": [
        {
            "label": "primary",
            "search_query": topic,
            "ranking_query": f"What recent evidence, customer language, market signals, and buying-friction patterns matter for {topic}?",
            "sources": [],
            "weight": 1.0,
        }
    ],
    "notes": ["everlearn-generated-lightweight-plan"],
}
print(json.dumps(plan))
PY
  forward_args+=("--plan" "$plan_file")
fi

set +e
SIGNALSWEEP_MEMORY_DIR="$signal_dir" "$signalsweep_python" "$signalsweep_dir/scripts/signalsweep.py" "$topic" \
  "${forward_args[@]}" \
  --emit=compact \
  --save-dir="$signal_dir" \
  --save-suffix=everlearn \
  >"$stdout_file" 2>"$stderr_file"
status=$?
set -e

if [ "$status" -ne 0 ]; then
  printf "SignalSweep failed for topic: %s\n\n" "$topic" >&2
  sed -n '1,120p' "$stderr_file" >&2
  exit "$status"
fi

saved_files="$(sed -n 's/^\[signalsweep\] Saved output to //p' "$stderr_file")"
if [ -z "$saved_files" ]; then
  saved_files="$(find "$signal_dir" -type f -name '*-raw-everlearn.*' -mtime -1 | sort | tail -5)"
fi

vault_real="$(cd "$EVERLEARN_VAULT" && pwd -P)"

if [ -z "$title" ]; then
  title="SignalSweep research: $topic"
fi

{
  printf "SignalSweep ran for: %s\n\n" "$topic"
  printf "## SignalSweep Artifacts\n\n"
  if [ -n "$saved_files" ]; then
    while IFS= read -r artifact; do
      [ -n "$artifact" ] || continue
      artifact_real="$(cd "$(dirname "$artifact")" 2>/dev/null && pwd -P)/$(basename "$artifact")"
      rel="${artifact_real#$vault_real/}"
      if [ "$rel" != "$artifact_real" ] && [ "${artifact##*.}" = "md" ]; then
        printf -- "- [[%s]]\n" "${rel%.md}"
      else
        printf -- "- %s\n" "$artifact"
      fi
    done <<EOF
$saved_files
EOF
  else
    printf -- "- No saved artifact path was reported.\n"
  fi
  printf "\n## SignalSweep Output\n\n"
  cat "$stdout_file"
  printf "\n"
} > "$body_file"

"$script_dir/capture.sh" \
  --type "$note_type" \
  --title "$title" \
  --profile "$profile" \
  --source "SignalSweep" \
  --tags "$extra_tags" \
  --body-file "$body_file"

printf "SignalSweep artifacts directory: %s\n" "$signal_dir"
