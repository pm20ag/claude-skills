#!/bin/bash
# Absorb manual edits to a playlist: show the diff, log adds/cuts as taste signal
# to feedback.tsv, flag any added artists that still need tags, then re-snapshot.
# Usage: ./learn.sh "Playlist Name"
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
NAME="${1:?Usage: learn.sh \"Playlist Name\"}"
FB="$DIR/feedback.tsv"

if ! out=$("$DIR/diff.sh" "$NAME" 2>&1); then
  echo "$out"; exit 1
fi

# Human-readable part (everything before the marker).
echo "$out" | sed '/---FEEDBACK---/,$d'

# Machine tail: action \t id \t artist \t name
fb=$(echo "$out" | sed -n '/---FEEDBACK---/,$p' | tail -n +2 | sed '/^$/d')
if [ -z "$fb" ]; then
  echo "Nothing to learn — baseline already current."
  exit 0
fi

[ -f "$FB" ] || printf 'date\tplaylist\taction\tartist\tname\n' > "$FB"
today=$(date +%Y-%m-%d)
while IFS=$'\t' read -r action id artist name; do
  printf '%s\t%s\t%s\t%s\t%s\n' "$today" "$NAME" "$action" "$artist" "$name" >> "$FB"
done <<< "$fb"

echo ""
echo "Logged $(echo "$fb" | wc -l | tr -d ' ') change(s) to feedback.tsv."

# Flag added artists missing from the tag file (Claude derives + appends rows).
echo "$fb" | awk -F'\t' '$1=="added"{print $3}' | sort -u | while read -r ar; do
  [ -z "$ar" ] && continue
  if ! awk -F'\t' -v a="$ar" 'NR>1 && $1==a{f=1} END{exit !f}' "$DIR/artist_tags.tsv"; then
    echo "  NEEDS TAG → $ar"
  fi
done

"$DIR/snapshot.sh" "$NAME" >/dev/null
echo "Re-snapshotted \"$NAME\" as the new baseline."
