# Vibe Playlist

Build Apple Music playlists from **your own library** by describing a vibe — a few words,
optionally some seed songs and parameters (length, era, artists) — and Claude Code curates
and creates the playlist. No streaming-service AI, no API keys: it reads your local Music
library via AppleScript and arranges what you already own.

It also includes a **reverse-Wrapped taste profiler** ("what's my sound?") that names your
eras and turns them into one-tap playlist seeds.

## Requirements
- macOS with the **Music** app and a local library
- **Claude Code**
- Python 3 (ships with macOS)
- On first run, macOS shows a one-time **Automation** prompt — *"… wants to control Music"* —
  click OK. (That's the only permission needed.)

## Install

### Option A — Portable (quickest)
```bash
unzip vibe-playlist.zip && cd vibe-playlist
./install.sh
```
This copies the tooling to `~/vibe-playlists/`, installs the skill to
`~/.claude/skills/vibe-playlist/`, seeds the artist-tag knowledge base, and builds your
library cache. Then open Claude Code and ask for a playlist.

### Option B — Claude Code plugin
This plugin ships inside the `claude-skills` marketplace repo. Once that's on GitHub:
```
/plugin marketplace add pm20ag/claude-skills
/plugin install vibe-playlist
```
On first use the skill bootstraps `~/vibe-playlists/` from the bundled `scripts/` and builds
your cache. Manifest fields are verified against the current Claude Code plugin docs, the
name/repo are filled in, and the repo is MIT licensed — ready to publish.

## Use it
Just talk to Claude Code:
- "Make a ~25-track late-night lowkey playlist, something like [artist]."
- "Chill version of my Gym playlist."
- "What's my sound?" → taste profile.

## What's included
| Path | Purpose |
|------|---------|
| `scripts/` | The AppleScript + shell + Python toolchain |
| `scripts/artist_tags.seed.tsv` | Seed knowledge base (~290 artists → genre/region/era/energy/mood) |
| `skills/vibe-playlist/SKILL.md` | The skill that drives Claude |
| `install.sh` | Portable installer |
| `.claude-plugin/` | Plugin + marketplace manifests |

## Notes
- Only arranges songs already in your library (can't pull from the Apple Music catalog).
- Every playlist is reversible: `osascript -e 'tell application "Music" to delete user playlist "NAME"'`
- After adding music, run `~/vibe-playlists/refresh.sh` to refresh the cache.
- The artist-tag base grows itself: any untagged artist gets tagged the first time it's used.
