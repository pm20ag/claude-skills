#!/bin/bash
# List the user's Apple Music playlists with track counts.
# Usage: ./list_playlists.sh
set -euo pipefail
osascript <<'EOF' 2>&1
set tabChar to (character id 9)
tell application "Music"
  set out to ""
  repeat with p in (get every user playlist)
    try
      set out to out & (count of tracks of p) & tabChar & (name of p) & linefeed
    end try
  end repeat
  return out
end tell
EOF