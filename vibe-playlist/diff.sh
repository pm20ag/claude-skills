#!/bin/bash
# Show what changed in a playlist since its last snapshot (added/removed/reordered).
# Does NOT update the baseline — re-run snapshot.sh after acting on the diff.
# Usage: ./diff.sh "Playlist Name"
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
NAME="${1:?Usage: diff.sh \"Playlist Name\"}"
SNAPDIR="$DIR/snapshots"
slug=$(python3 "$DIR/_slug.py" "$NAME")
SNAP="$SNAPDIR/$slug.tsv"

if [ ! -f "$SNAP" ]; then
  echo "No baseline snapshot for \"$NAME\". Run: ./snapshot.sh \"$NAME\"" >&2
  exit 2
fi

LIVE="$(mktemp /tmp/livepl.XXXXXX)"
trap 'rm -f "$LIVE"' EXIT
"$DIR/playlist_tracks.sh" "$NAME" | python3 "$DIR/_blob2tsv.py" "$LIVE" >/dev/null
python3 "$DIR/_diff.py" "$SNAP" "$LIVE"
