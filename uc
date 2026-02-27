#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HASH="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
LINE="<small>Commit de referencia: \`$HASH\`</small>"
GDRIVE_FOLDER_ID="1HjJZiyQejorhK12XxyUzS3CwV5f0QPoP"
DOCS=(
  "$REPO_ROOT/Git_Manual/git_manual.md:git_manual.md"
  "$REPO_ROOT/Git_Manual/bizu.md:bizu.mb"
)

update_header() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Arquivo nao encontrado: $file" >&2
    return 1
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
  ' "$file" > "$file.tmp"

  mv "$file.tmp" "$file"
  echo "Atualizado: $file -> $HASH"
}

for doc in "${DOCS[@]}"; do
  IFS=':' read -r local_file _ <<< "$doc"
  update_header "$local_file"
done

if ! command -v rclone >/dev/null 2>&1; then
  echo "Google Drive: rclone nao encontrado. Sync ignorado."
  exit 0
fi

REMOTE="${RCLONE_REMOTE:-}"
if [[ -z "$REMOTE" ]]; then
  mapfile -t remotes < <(rclone listremotes 2>/dev/null | sed 's/:$//')
  if [[ "${#remotes[@]}" -eq 1 ]]; then
    REMOTE="${remotes[0]}"
  elif printf '%s\n' "${remotes[@]}" | grep -qx "gdrive"; then
    REMOTE="gdrive"
  elif printf '%s\n' "${remotes[@]}" | grep -qx "bizu"; then
    REMOTE="bizu"
  else
    echo "Google Drive: defina RCLONE_REMOTE (ex.: export RCLONE_REMOTE=gdrive). Sync ignorado."
    exit 0
  fi
fi

echo "Google Drive: usando remote '$REMOTE'"

for doc in "${DOCS[@]}"; do
  IFS=':' read -r local_file remote_name <<< "$doc"
  DEST="${REMOTE},root_folder_id=${GDRIVE_FOLDER_ID}:${remote_name}"
  if rclone copyto "$local_file" "$DEST"; then
    echo "Google Drive: arquivo atualizado em $DEST"
  else
    echo "Google Drive: falha no upload de $local_file. Verifique remote e permissao da pasta."
  fi
done
