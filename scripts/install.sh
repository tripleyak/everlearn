#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  curl -fsSL https://raw.githubusercontent.com/tripleyak/everlearn/v2026-05-27-workshop/scripts/install.sh | bash -s -- --ref v2026-05-27-workshop [setup options]

Examples:
  curl -fsSL https://raw.githubusercontent.com/tripleyak/everlearn/v2026-05-27-workshop/scripts/install.sh | bash -s -- --ref v2026-05-27-workshop --profile ecommerce
  curl -fsSL https://raw.githubusercontent.com/tripleyak/everlearn/v2026-05-27-workshop/scripts/install.sh | bash -s -- --ref v2026-05-27-workshop --profile general --vault "$HOME/Documents/My Vault"

Installer options:
  --ref REF            Git ref to install from. Default: main
  --repo OWNER/REPO    GitHub repository. Default: tripleyak/everlearn
  --install-dir DIR    Source install directory. Default: ~/.everlearn/source
  --no-verify          Skip final everlearn verify

Setup options are passed through to scripts/setup.sh:
  --profile general|ecommerce|coding|research|operations
  --vault PATH
  --no-claude
  --no-codex
  --no-agents
USAGE
}

repo="${EVERLEARN_REPO:-tripleyak/everlearn}"
ref="${EVERLEARN_REF:-main}"
install_dir="${EVERLEARN_INSTALL_DIR:-$HOME/.everlearn/source}"
run_verify=1
setup_args=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --ref)
      ref="${2:-}"
      shift 2
      ;;
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --install-dir)
      install_dir="${2:-}"
      shift 2
      ;;
    --no-verify)
      run_verify=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      setup_args+=("$1")
      shift
      ;;
  esac
done

if [ -z "$repo" ] || [ -z "$ref" ] || [ -z "$install_dir" ]; then
  printf "Missing required installer value.\n\n" >&2
  usage >&2
  exit 2
fi

for required in curl tar; do
  if ! command -v "$required" >/dev/null 2>&1; then
    printf "Required command not found: %s\n" "$required" >&2
    exit 1
  fi
done

case "$install_dir" in
  ""|"/"|"$HOME"|"$HOME/"|".")
    printf "Refusing unsafe install directory: %s\n" "$install_dir" >&2
    exit 2
    ;;
esac

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/everlearn-install.XXXXXX")"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

src_dir="$tmp_dir/source"
mkdir -p "$src_dir" "$(dirname "$install_dir")"

tarball_url="https://codeload.github.com/$repo/tar.gz/$ref"
printf "Downloading Everlearn from %s at %s...\n" "$repo" "$ref"
curl -fsSL "$tarball_url" | tar -xz -C "$src_dir" --strip-components=1

if [ ! -x "$src_dir/scripts/setup.sh" ]; then
  printf "Downloaded package does not contain executable scripts/setup.sh.\n" >&2
  exit 1
fi

staging_dir="$install_dir.tmp.$$"
rm -rf "$staging_dir"
mv "$src_dir" "$staging_dir"
rm -rf "$install_dir"
mv "$staging_dir" "$install_dir"

printf "Installed Everlearn source: %s\n" "$install_dir"
"$install_dir/scripts/setup.sh" "${setup_args[@]}"

if [ "$run_verify" -eq 1 ]; then
  "$HOME/.everlearn/bin/everlearn" verify
fi
