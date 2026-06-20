#!/bin/bash
# Dump a playlist's tracks as TSV (persistentID, name, artist) — use as a SOURCE
# pool that the matcher then filters/curates by vibe.
# Usage: ./playlist_tracks.sh "Playlist Name"
set -euo pipefail
NAME="${1:?Usage: playlist_tracks.sh \"Playlist Name\"}"

osascript <<EOF 2>&1
set tabChar to (character id 9)
set recSep to (character id 30)
set plName to "$NAME"
tell application "Music"
  set pl to (first user playlist whose name is plName)
  set ids to persistent ID of every track of pl
  set nms to name of every track of pl
  set ars to artist of every track of pl
end tell
set AppleScript's text item delimiters to tabChar
set blob to (ids as text) & recSep & (nms as text) & recSep & (ars as text)
set AppleScript's text item delimiters to ""
return blob
EOF