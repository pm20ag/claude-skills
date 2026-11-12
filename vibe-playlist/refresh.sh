#!/bin/bash
# Refresh the local library cache (~/vibe-playlists/library.tsv).
# Run this whenever you've added songs to Apple Music since the last build.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
BLOB="$(mktemp /tmp/vibelib.XXXXXX)"
trap 'rm -f "$BLOB"' EXIT

osascript "$DIR/export_library.applescript" > "$BLOB"
python3 "$DIR/transpose.py" "$BLOB" "$DIR/library.tsv"