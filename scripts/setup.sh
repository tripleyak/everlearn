#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_source="$repo_root/skills/everlearn"

# shellcheck source=../skills/everlearn/scripts/lib.sh
. "$skill_source/scripts/lib.sh"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/setup.sh [--profile general] [--vault "$HOME/Everlearn Vault"] [--no-claude] [--no-codex] [--no-agents]

Profiles:
  general, ecommerce, coding, research, operations
USAGE
}

profile="general"
vault="$HOME/Everlearn Vault"
install_claude=1
install_codex=1
install_agents=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --vault)
      vault="${2:-}"
      shift 2
      ;;
    --no-claude)
      install_claude=0
      shift
      ;;
    --no-codex)
      install_codex=0
      shift
      ;;
    --no-agents)
      install_agents=0
      shift
      ;;
    --yes)
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf "Unknown option: %s\n\n" "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$profile" in
  general|ecommerce|coding|research|operations) ;;
  *)
    printf "Unknown profile: %s\n" "$profile" >&2
    exit 2
    ;;
esac

everlearn_home="$HOME/.everlearn"
config_file="$everlearn_home/config"
mkdir -p "$everlearn_home/bin" "$everlearn_home/scripts"

EVERLEARN_VAULT="$vault"
EVERLEARN_PROFILE="$profile"
ensure_vault_folders

{
  printf "EVERLEARN_VAULT="
  shell_quote "$vault"
  printf "\nEVERLEARN_PROFILE="
  shell_quote "$profile"
  printf "\nEVERLEARN_SOURCE="
  shell_quote "$repo_root"
  printf "\n"
} > "$config_file"

copy_skill() {
  target_parent="$1"
  target="$target_parent/everlearn"
  mkdir -p "$target"
  (cd "$skill_source" && tar cf - .) | (cd "$target" && tar xf -)
}

if [ "$install_claude" -eq 1 ]; then
  copy_skill "$HOME/.claude/skills"
fi

if [ "$install_codex" -eq 1 ]; then
  copy_skill "$HOME/.codex/skills"
fi

if [ "$install_agents" -eq 1 ]; then
  copy_skill "$HOME/.agents/skills"
fi

(cd "$skill_source/scripts" && tar cf - .) | (cd "$everlearn_home/scripts" && tar xf -)
chmod +x "$everlearn_home/scripts/"*.sh

cat > "$everlearn_home/bin/everlearn" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail

everlearn_home="${EVERLEARN_HOME:-$HOME/.everlearn}"
script_dir="$everlearn_home/scripts"
command="${1:-help}"

case "$command" in
  capture)
    shift
    exec "$script_dir/capture.sh" "$@"
    ;;
  review|weekly-review)
    shift
    exec "$script_dir/weekly-review.sh" "$@"
    ;;
  verify)
    shift
    exec "$script_dir/verify.sh" "$@"
    ;;
  help|-h|--help)
    cat <<'HELP'
Everlearn commands:
  everlearn capture --title "Title" --type learning "Body text"
  everlearn review
  everlearn verify
HELP
    ;;
  *)
    printf "Unknown Everlearn command: %s\n" "$command" >&2
    exit 2
    ;;
esac
WRAPPER
chmod +x "$everlearn_home/bin/everlearn"

printf "Everlearn setup complete.\n"
printf "Vault: %s\n" "$vault"
printf "Profile: %s\n" "$profile"
printf "Command: %s\n" "$everlearn_home/bin/everlearn"
printf "\nOpen the vault in Obsidian with: Open folder as vault -> %s\n" "$vault"

