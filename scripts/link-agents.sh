#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_SRC="$REPO_ROOT/agents"
AGENTS_DEST="$HOME/.claude/agents"

mkdir -p "$AGENTS_DEST"

find "$AGENTS_SRC" -name "*.md" | while read -r src; do
  filename="$(basename "$src")"
  dest="$AGENTS_DEST/$filename"
  ln -sfn "$src" "$dest"
  echo "linked: $filename"
done
