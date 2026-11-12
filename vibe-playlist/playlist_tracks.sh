#!/bin/bash
# Dump a playlist's tracks as TSV (persistentID, name, artist) — use as a SOURCE
# pool that the matcher then filters/curates by vibe.
# Usage: ./playlist_tracks.sh "Playlist Name"
#
# Resolves the playlist by persistent ID (matched byte-exact in Python) rather than
# `whose name is`, because AppleScript folds distinct emoji (🌙/🌑) as equal.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
NAME="${1:?Usage: playlist_tracks.sh \"Playlist Name\"}"

PID="$(osascript "$DIR/_list_playlists_id.applescript" | python3 "$DIR/_resolve.py" "$NAME")"
[ -n "$PID" ] || { echo "Playlist not found: $NAME" >&2; exit 3; }

osascript - "$PID" <<'EOF' 2>&1
on run argv
	set thePid to item 1 of argv
	set tabChar to (character id 9)
	set recSep to (character id 30)
	tell application "Music"
		set pl to (first user playlist whose persistent ID is thePid)
		set ids to persistent ID of every track of pl
		set nms to name of every track of pl
		set ars to artist of every track of pl
	end tell
	set AppleScript's text item delimiters to tabChar
	set blob to (ids as text) & recSep & (nms as text) & recSep & (ars as text)
	set AppleScript's text item delimiters to ""
	return blob
end run
EOF