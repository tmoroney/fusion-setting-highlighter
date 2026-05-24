#!/bin/sh
set -eu

REPO_URL="${FUSION_SETTING_REPO_URL:-https://github.com/tmoroney/fusion-setting-highlighter}"
REF="${FUSION_SETTING_REF:-main}"
EXTENSION_DIR_NAME="fusion-setting"

editor="${1:-vscode}"

case "$editor" in
  vscode)
    install_dir="$HOME/.vscode/extensions/$EXTENSION_DIR_NAME"
    ;;
  cursor)
    install_dir="$HOME/.cursor/extensions/$EXTENSION_DIR_NAME"
    ;;
  windsurf)
    install_dir="$HOME/.windsurf/extensions/$EXTENSION_DIR_NAME"
    ;;
  antigravity)
    install_dir="$HOME/.antigravity/extensions/$EXTENSION_DIR_NAME"
    ;;
  *)
    echo "Unknown editor: $editor" >&2
    echo "Usage: install.sh [vscode|cursor|windsurf|antigravity]" >&2
    exit 1
    ;;
esac

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT INT TERM

archive_url="$REPO_URL/archive/refs/heads/$REF.tar.gz"

echo "Downloading $archive_url"
curl -fsSL "$archive_url" | tar -xz -C "$tmp_dir"

source_dir="$(find "$tmp_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

mkdir -p "$install_dir"
cp "$source_dir/package.json" "$install_dir/package.json"
cp "$source_dir/language-configuration.json" "$install_dir/language-configuration.json"
rm -rf "$install_dir/syntaxes"
cp -R "$source_dir/syntaxes" "$install_dir/syntaxes"

echo "Installed Fusion Setting to $install_dir"
echo "Restart your editor, then open a .setting file."
