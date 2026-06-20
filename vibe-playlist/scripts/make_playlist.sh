#!/bin/bash
# Create an Apple Music playlist from a list of persistent track IDs.
# Usage:  ./make_playlist.sh "Playlist Name" < ids.txt
#         echo "ID1,ID2,ID3" | ./make_playlist.sh "Playlist Name"
# IDs may be separated by commas, spaces, or newlines.
set -euo pipefail
NAME="${1:?Usage: make_playlist.sh \"Playlist Name\" < ids.txt}"

# Normalise stdin to a single comma-separated string.
IDS="$(tr ', \n\t' '\n\n\n\n' | grep -v '^$' | paste -sd, -)"
[ -n "$IDS" ] || { echo "No track IDs provided on stdin." >&2; exit 1; }

osascript <<EOF 2>&1
set idList to "$IDS"
set plName to "$NAME"
set AppleScript's text item delimiters to ","
set ids to text items of idList
set AppleScript's text item delimiters to ""
tell application "Music"
	set newPl to make new user playlist with properties {name:plName}
	set added to 0
	set missing to 0
	repeat with anId in ids
		try
			set t to (first track of library playlist 1 whose persistent ID is (anId as string))
			duplicate t to newPl
			set added to added + 1
		on error
			set missing to missing + 1
		end try
	end repeat
	return "Created '" & (name of newPl) & "' — " & added & " tracks added, " & missing & " not found."
end tell
EOF