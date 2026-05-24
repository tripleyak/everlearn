#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$script_dir/lib.sh"

usage() {
  cat <<'USAGE'
Usage:
  everlearn capture --title "Title" [--type learning] [--profile general] [--source "Source"] [--tags "tag1,tag2"] "Body text"
  everlearn capture --title "Title" --body-file /path/to/body.md

Types:
  learning, decision, research, signal, workflow, prompt, source, review, inbox
USAGE
}

load_config

type="learning"
title=""
profile="$EVERLEARN_PROFILE"
source_label=""
tags=""
body_file=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --type)
      type="${2:-}"
      shift 2
      ;;
    --title)
      title="${2:-}"
      shift 2
      ;;
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --source)
      source_label="${2:-}"
      shift 2
      ;;
    --tags)
      tags="${2:-}"
      shift 2
      ;;
    --body-file)
      body_file="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      printf "Unknown option: %s\n\n" "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "$title" ]; then
  printf "Missing required --title.\n\n" >&2
  usage >&2
  exit 2
fi

if [ -n "$body_file" ]; then
  if [ ! -f "$body_file" ]; then
    printf "Body file not found: %s\n" "$body_file" >&2
    exit 1
  fi
  body="$(cat "$body_file")"
elif [ "$#" -gt 0 ]; then
  body="$*"
elif [ ! -t 0 ]; then
  body="$(cat)"
else
  body="_Add details here._"
fi

ensure_vault_folders

folder="$(folder_for_type "$type")"
target_dir="$EVERLEARN_VAULT/$folder"
mkdir -p "$target_dir"

timestamp="$(date +%Y-%m-%d-%H%M%S)"
created="$(date +%Y-%m-%dT%H:%M:%S%z)"
slug="$(safe_slug "$title")"
if [ -z "$slug" ]; then
  slug="note"
fi

note_path="$target_dir/$timestamp-$slug.md"
escaped_title="$(yaml_escape "$title")"
escaped_source="$(yaml_escape "$source_label")"

{
  printf -- "---\n"
  printf 'title: "%s"\n' "$escaped_title"
  printf "type: %s\n" "$type"
  printf "profile: %s\n" "$profile"
  printf "created: %s\n" "$created"
  if [ -n "$source_label" ]; then
    printf 'source: "%s"\n' "$escaped_source"
  fi
  printf "tags:\n"
  write_tags "$profile" "$type" "$tags"
  printf -- "---\n\n"
  printf "# %s\n\n" "$title"
  printf "## Capture\n\n"
  printf "%s\n\n" "$body"
  printf "## Why It Matters\n\n"
  printf -- "- \n\n"
  printf "## Reuse\n\n"
  printf -- "- \n\n"
  printf "## Links\n\n"
  printf -- "- \n"
} > "$note_path"

printf "Everlearn captured: %s\n" "$note_path"

