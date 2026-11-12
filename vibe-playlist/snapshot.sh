#!/bin/bash
# Save the current track list of a playlist as the baseline for future diffs.
# Usage: ./snapshot.sh "Playlist Name"
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
NAME="${1:?Usage: snapshot.sh \"Playlist Name\"}"
SNAPDIR="$DIR/snapshots"
mkdir -p "$SNAPDIR"

slug=$(python3 "$DIR/_slug.py" "$NAME")
count=$("$DIR/playlist_tracks.sh" "$NAME" | python3 "$DIR/_blob2tsv.py" "$SNAPDIR/$slug.tsv")

# Maintain an index: slug, name, timestamp, count
ts=$(date "+%Y-%m-%d %H:%M:%S")
touch "$SNAPDIR/index.tsv"
grep -v -F "	$NAME	" "$SNAPDIR/index.tsv" > "$SNAPDIR/index.tmp" 2>/dev/null || true
printf '%s\t%s\t%s\t%s\n' "$slug" "$NAME" "$ts" "$count" >> "$SNAPDIR/index.tmp"
mv "$SNAPDIR/index.tmp" "$SNAPDIR/index.tsv"

echo "Snapshot saved: \"$NAME\" — $count tracks ($ts)"
