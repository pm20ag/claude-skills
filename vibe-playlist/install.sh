#!/bin/bash
# Portable installer for the vibe-playlist skill.
# Run from inside the unzipped bundle:  ./install.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DATA="$HOME/vibe-playlists"
SKILLS="$HOME/.claude/skills/vibe-playlist"

echo "Installing vibe-playlist…"

# 1) Tooling + data dir
mkdir -p "$DATA"
cp "$HERE/scripts/"*.sh "$HERE/scripts/"*.py "$HERE/scripts/"*.applescript "$DATA/"
chmod +x "$DATA/"*.sh

# 2) Seed artist tags — only if the user doesn't already have their own
if [ ! -f "$DATA/artist_tags.tsv" ]; then
  cp "$HERE/scripts/artist_tags.seed.tsv" "$DATA/artist_tags.tsv"
  echo "  seeded artist_tags.tsv ($(($(wc -l < "$DATA/artist_tags.tsv") - 1)) artists)"
else
  echo "  kept existing artist_tags.tsv"
fi

# 3) Skill
mkdir -p "$SKILLS"
cp "$HERE/skills/vibe-playlist/SKILL.md" "$SKILLS/"

# 4) Build the library cache (prompts for Music control on first run)
echo "Building your library cache (approve the macOS prompt to control Music)…"
"$DATA/refresh.sh"

echo
echo "Done. Open Claude Code and say e.g.:  \"make a chill sunday playlist, ~20 tracks\""
echo "Tooling: $DATA   |   Skill: $SKILLS"
