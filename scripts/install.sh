#!/bin/sh
set -eu

REPO_URL="${FUSION_SETTING_REPO_URL:-https://github.com/tmoroney/fusion-setting-highlighter}"
REF="${FUSION_SETTING_REF:-master}"
EXTENSION_DIR_NAME="fusion-setting-highlighter"

prompt_for_editor() {
  echo "Choose an editor:"
  echo "  1) VS Code"
  echo "  2) Cursor"
  echo "  3) Windsurf"
  echo "  4) Antigravity"
  printf "Enter a number [1-4]: "
  IFS= read -r choice </dev/tty

  case "$choice" in
    1) editor="vscode" ;;
    2) editor="cursor" ;;
    3) editor="windsurf" ;;
    4) editor="antigravity" ;;
    *)
      echo "Invalid choice: $choice" >&2
      exit 1
      ;;
  esac
}

editor="${1:-${FUSION_SETTING_EDITOR:-}}"

if [ -z "$editor" ]; then
  prompt_for_editor
fi

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

echo "Installed Fusion Setting Highlighter to $install_dir"
echo "Restart your editor, then open a .setting file."
