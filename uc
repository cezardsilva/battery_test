#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
FILE="$REPO_ROOT/Git_Manual/git_manual.md"
HASH="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
LINE="<small>Commit de referencia: \`$HASH\`</small>"
GDRIVE_FOLDER_ID="1HjJZiyQejorhK12XxyUzS3CwV5f0QPoP"

if [[ ! -f "$FILE" ]]; then
  echo "Arquivo nao encontrado: $FILE" >&2
  exit 1
fi

awk -v new_line="$LINE" '
  BEGIN { inserted = 0; in_preamble = 1 }
  NR == 1 {
    print
    next
  }
  in_preamble && /^<small>Commit de referencia: `[^`]+`<\/small>$/ {
    next
  }
  in_preamble && /^[[:space:]]*$/ {
    next
  }
  in_preamble {
    print ""
    print new_line
    print ""
    in_preamble = 0
    inserted = 1
  }
  { print }
  END { if (!inserted) print "\n" new_line }
' "$FILE" > "$FILE.tmp"

mv "$FILE.tmp" "$FILE"

echo "Atualizado: $FILE -> $HASH"

if ! command -v rclone >/dev/null 2>&1; then
  echo "Google Drive: rclone nao encontrado. Sync ignorado."
  exit 0
fi

REMOTE="${RCLONE_REMOTE:-}"
if [[ -z "$REMOTE" ]]; then
  mapfile -t remotes < <(rclone listremotes 2>/dev/null | sed 's/:$//')
  if [[ "${#remotes[@]}" -eq 1 ]]; then
    REMOTE="${remotes[0]}"
  else
    echo "Google Drive: defina RCLONE_REMOTE (ex.: export RCLONE_REMOTE=gdrive). Sync ignorado."
    exit 0
  fi
fi

DEST="${REMOTE},root_folder_id=${GDRIVE_FOLDER_ID}:$(basename "$FILE")"
if rclone copyto "$FILE" "$DEST"; then
  echo "Google Drive: arquivo atualizado em $DEST"
else
  echo "Google Drive: falha no upload. Verifique rclone remote e permissao da pasta."
fi
