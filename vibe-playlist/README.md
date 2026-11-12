# Vibe Playlists

Build Apple Music playlists from **your own library** by describing a vibe.

## Use it (in Claude Code)
Just describe what you want, e.g.:

> "Make a 20-song late-night lowkey R&B playlist, something like Tems and Brent Faiyaz."

Claude picks matching tracks from your library and creates the playlist. The
`/vibe-playlist` skill (in `~/.claude/skills/`) drives this.

## What you can specify
- **Vibe** — a few words ("rainy sunday", "gym energy", "afro summer cookout")
- **Seed songs / artists** — anchors to build around
- **Length** — track count or duration (default ~25 tracks)
- **Constraints** — era, must-include / exclude artists, favorites-only vs deep cuts

## Files
| File | Purpose |
|------|---------|
| `library.tsv` | Cached library (id, name, artist, album, genre, year, plays, duration) |
| `refresh.sh` | Rebuild the cache after adding songs to Apple Music |
| `export_library.applescript` | Pulls library data out of Music |
| `transpose.py` | Shapes the export into `library.tsv` |
| `make_playlist.sh` | Creates a playlist from a list of track IDs |

## Notes
- Only arranges songs you **already own** in your library.
- Reversible — delete any playlist:
  `osascript -e 'tell application "Music" to delete user playlist "NAME"'`
- Refresh the cache when you've added music: `~/claude-skills/vibe-playlist/refresh.sh`
- Mac-only (uses AppleScript + the Music app).
