---
name: vibe-playlist
description: Build an Apple Music playlist from the user's own library by vibe. Use when the user describes a mood/vibe in a few words (optionally with seed/example songs and parameters like length, era, artists to include/exclude) and wants a playlist made. Triggers on "make a playlist", "vibe", "playlist of", "songs like", or any request to generate/curate a playlist from their music.
---

# Vibe Playlist

Turn a short vibe description (plus optional seed songs and parameters) into a real
Apple Music playlist built from the user's **own library**. All tooling and data live in
`~/vibe-playlists/`.

## Setup (first run)
If `~/vibe-playlists/refresh.sh` is missing, bootstrap it:
1. `mkdir -p ~/vibe-playlists`
2. Copy the bundled scripts into it. If this skill was installed as a Claude Code plugin,
   the scripts ship alongside it under the plugin root's `scripts/` dir; otherwise they were
   placed by `install.sh`. Also seed tags: `cp scripts/artist_tags.seed.tsv ~/vibe-playlists/artist_tags.tsv`
   (only if `artist_tags.tsv` doesn't already exist — never overwrite a user's tags).
3. `chmod +x ~/vibe-playlists/*.sh`
4. Run `~/vibe-playlists/refresh.sh` to build `library.tsv` from the user's Music library.
   The first `osascript` call triggers a one-time macOS prompt to control Music — tell the
   user to approve it.

## Tooling
- `~/vibe-playlists/library.tsv` — cached library. Columns (tab-separated):
  `persistentID  name  artist  album  genre  year  plays  durationSec  dateAdded`. Grep this;
  do **not** read the whole file into context.
- `~/vibe-playlists/artist_tags.tsv` — **derived** per-artist tags (the genre/vibe
  source of truth — trust these over Apple's `genre` column, which is unreliable).
  Columns: `artist  derived_genre  region  era  energy  mood`. `energy` is 1-5;
  `region` is a scene/country code (e.g. "UK (London)", "NG (Lagos)", "US (Atlanta)").
  Partial coverage — ships with a seed; the tail is filled lazily (below).
- `~/vibe-playlists/untagged.sh [N]` — lists library artists with no tags yet, by
  track count. Use to find which candidate artists need lazy tagging.
- `~/vibe-playlists/refresh.sh` — rebuild `library.tsv` (run if songs were added).
- `~/vibe-playlists/make_playlist.sh "Name" < ids` — create a playlist from a list
  of persistent IDs (comma/space/newline separated on stdin).
- `~/vibe-playlists/list_playlists.sh` — list the user's playlists with track counts.
- `~/vibe-playlists/playlist_tracks.sh "Name"` — dump a playlist's tracks (RecordSep-
  joined id/name/artist blob) to use as a **source pool** instead of the whole library.
- `~/vibe-playlists/profile.py` — taste-profile stats (see reverse-Wrapped below).

## Sources & filters
- Default source is the whole library (`library.tsv`). If the user names a playlist as the
  source ("a chill version of my Gym playlist", "mellow cuts from my Shazams"), pull that
  pool with `playlist_tracks.sh`, join its persistent IDs to `library.tsv` (year/dateAdded)
  and artists to `artist_tags.tsv`, then filter/curate as usual.
- **Filters**: `year` column = release year; `dateAdded` = when added (use for "recent" /
  era windows); plus derived_genre / region / energy / mood. Combine freely.

## Know the user before defaulting
Every library is different. Do NOT assume a default genre. Read the user's actual taste from
their data before curating: lifetime `plays` shows long-term favourites, while `dateAdded`
(recent years) shows current taste — these often diverge. When in doubt, run `profile.py`
or skim the library first. For "favorites/nostalgia" lean on `plays`; for "what I'm into now"
prefer recently-added tracks.

## Inputs to gather (ask only if missing and it matters)
- **Vibe**: the few-word description. Required.
- **Seed songs / artists**: anchors. Optional but very useful.
- **Length**: track count or duration. Default ~25 tracks (~90 min) if unspecified.
- **Constraints**: era/year range, must-include / exclude artists, "favorites only"
  vs "deep cuts / discovery", explicit/clean, etc.

## Workflow
1. **Freshness**: if the user mentions newly added songs, run `~/vibe-playlists/refresh.sh` first.
2. **Translate the vibe** into concrete signals: derived_genre(s), region, era, energy
   band, and mood words. Use seed songs — look them up, read their artists' rows in
   `artist_tags.tsv`, and expand to artists with similar derived_genre/region/mood.
3. **Find candidates** by grepping `library.tsv`, then **join against `artist_tags.tsv`**
   to filter by derived_genre / region / era / energy / mood — NOT Apple's `genre` column.
   Keep the candidate pool focused.
4. **Lazy-tag the tail**: any candidate artist missing from `artist_tags.tsv` — derive
   `derived_genre region era energy mood` from your own knowledge and **append a row** to
   the file (`>> ~/vibe-playlists/artist_tags.tsv`). This makes the tag set self-complete
   through use; never skip a track just because its artist wasn't pre-tagged.
5. **Curate to length**: pick and order tracks. Use `energy`/`mood` (and per-song nuance
   from your own knowledge) to honor the vibe; weight `plays` high for "favorites", low
   for "discovery". **Cap any single artist to ~2-3 tracks** unless the user asked for one
   artist — otherwise play-count ranking clumps the playlist. Open strong, sequence for
   flow, avoid duplicate songs unless intended.
6. **Create**: pipe the chosen persistent IDs to `make_playlist.sh` with a descriptive
   name (a leading emoji + the vibe reads nicely, e.g. "🌙 Late Night Lowkey").
7. **Report**: show a compact table of what went in (artist – title, maybe plays), note
   anything you couldn't honor, and offer quick tweaks: regenerate, longer/shorter,
   swap an artist, reorder, or delete.

## Taste profile (reverse-Wrapped)
When the user asks for a taste profile / "Wrapped" / "what's my sound": run
`python3 ~/vibe-playlists/profile.py` for the stats, then narrate vivid persona/era
descriptors and surface a few named "vibes" — each phrased as a ready playlist seed the
matcher can build. Distinguish nostalgia (lifetime plays) from current taste (recent adds).

## Constraints to remember (and tell the user when relevant)
- Only arranges songs **already in their library** — can't add catalog tracks they don't own.
- Fully reversible: delete with
  `osascript -e 'tell application "Music" to delete user playlist "NAME"'`.
- Edits sync to their other devices via iCloud Music Library.
- Mac-only (depends on AppleScript + the Music app).
