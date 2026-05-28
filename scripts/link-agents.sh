#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_SRC="$REPO_ROOT/agents"
AGENTS_DEST="$HOME/.claude/agents"

mkdir -p "$AGENTS_DEST"

find "$AGENTS_SRC" -name "*.md" \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -print0 |
while IFS= read -r -d '' src; do
  filename="$(basename "$src")"
  dest="$AGENTS_DEST/$filename"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    rm -f "$dest"
  fi

  ln -sfn "$src" "$dest"
  echo "linked: $filename"
done
