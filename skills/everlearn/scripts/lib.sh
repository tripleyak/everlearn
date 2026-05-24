#!/usr/bin/env bash
set -euo pipefail

everlearn_home="${EVERLEARN_HOME:-$HOME/.everlearn}"
config_file="${EVERLEARN_CONFIG:-$everlearn_home/config}"

shell_quote() {
  printf "'%s'" "$(printf "%s" "$1" | sed "s/'/'\\\\''/g")"
}

yaml_escape() {
  printf "%s" "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

safe_slug() {
  printf "%s" "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs '[:alnum:]' '-' \
    | sed 's/^-//; s/-$//; s/--*/-/g' \
    | cut -c 1-70
}

load_config() {
  EVERLEARN_VAULT="${EVERLEARN_VAULT:-$HOME/Everlearn Vault}"
  EVERLEARN_PROFILE="${EVERLEARN_PROFILE:-general}"
  if [ -f "$config_file" ]; then
    # shellcheck disable=SC1090
    . "$config_file"
  fi
}

folder_for_type() {
  case "$1" in
    learning) printf "10 Learnings" ;;
    decision) printf "20 Decisions" ;;
    research) printf "30 Research" ;;
    signal) printf "30 Research/Customer Signals" ;;
    workflow) printf "40 Workflows" ;;
    prompt) printf "40 Workflows/Prompts" ;;
    source) printf "50 Sources" ;;
    review) printf "60 Reviews" ;;
    inbox|idea) printf "00 Inbox" ;;
    *) printf "00 Inbox" ;;
  esac
}

ensure_vault_folders() {
  mkdir -p \
    "$EVERLEARN_VAULT/00 Inbox" \
    "$EVERLEARN_VAULT/10 Learnings" \
    "$EVERLEARN_VAULT/20 Decisions" \
    "$EVERLEARN_VAULT/30 Research/Customer Signals" \
    "$EVERLEARN_VAULT/40 Workflows/Prompts" \
    "$EVERLEARN_VAULT/50 Sources" \
    "$EVERLEARN_VAULT/60 Reviews" \
    "$EVERLEARN_VAULT/90 Archive"
}

write_tags() {
  profile="$1"
  type="$2"
  extra="${3:-}"

  printf "  - everlearn\n"
  printf "  - %s\n" "$profile"
  printf "  - %s\n" "$type"

  if [ -n "$extra" ]; then
    old_ifs="$IFS"
    IFS=","
    for tag in $extra; do
      clean_tag="$(printf "%s" "$tag" | sed 's/^ *//; s/ *$//')"
      if [ -n "$clean_tag" ]; then
        printf "  - %s\n" "$clean_tag"
      fi
    done
    IFS="$old_ifs"
  fi
}

