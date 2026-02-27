#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
FILE="$REPO_ROOT/Git_Manual/git_manual.md"
HASH="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
LINE="<small>Commit de referencia: \`$HASH\`</small>"

if [[ ! -f "$FILE" ]]; then
  echo "Arquivo nao encontrado: $FILE" >&2
  exit 1
fi

awk -v new_line="$LINE" '
  BEGIN { replaced = 0; inserted = 0 }
  /^<small>Commit de referencia: `[^`]+`<\/small>$/ {
    if (!replaced) {
      print new_line
      replaced = 1
    }
    next
  }
  NR == 1 {
    print
    next
  }
  NR == 2 && !replaced {
    print ""
    print new_line
    print ""
    inserted = 1
  }
  { print }
  END {
    if (!replaced && !inserted) {
      print ""
      print new_line
    }
  }
' "$FILE" > "$FILE.tmp"

mv "$FILE.tmp" "$FILE"

echo "Atualizado: $FILE -> $HASH"
