---
name: vibe-playlist-personal
description: Build an Apple Music playlist from the user's own library by vibe. Use when the user describes a mood/vibe in a few words (optionally with seed/example songs and parameters like length, era, artists to include/exclude) and wants a playlist made. Triggers on "make a playlist", "vibe", "playlist of", "songs like", or any request to generate/curate a playlist from their music.
---

# Vibe Playlist

Turn a short vibe description (plus optional seed songs and parameters) into a real
Apple Music playlist built from the user's **own library**. All tooling lives in
`~/vibe-playlists/`.

## Tooling
- `~/vibe-playlists/library.tsv` — cached library. Columns (tab-separated):
  `persistentID  name  artist  album  genre  year  plays  durationSec`. Grep this;
  do **not** read the whole file into context.
- `~/vibe-playlists/artist_tags.tsv` — **derived** per-artist tags (the genre/vibe
  source of truth — trust these over Apple's `genre` column, which is unreliable).
  Columns: `artist  derived_genre  region  era  energy  mood`. `energy` is 1-5;
  `region` is a scene/country code (e.g. "UK (London)", "NG (Lagos)", "US (Atlanta)").
  Partial coverage — head artists are pre-tagged; the tail is filled lazily (below).
- `~/vibe-playlists/untagged.sh [N]` — lists library artists with no tags yet, by
  track count. Use to find which candidate artists need lazy tagging.
- `~/vibe-playlists/refresh.sh` — rebuild `library.tsv` (run if songs were added).
- `~/vibe-playlists/make_playlist.sh "Name" < ids` — create a playlist from a list
  of persistent IDs (comma/space/newline separated on stdin).
- `~/vibe-playlists/list_playlists.sh` — list the user's playlists with track counts.
- `~/vibe-playlists/playlist_tracks.sh "Name"` — dump a playlist's tracks (RecordSep-
  joined id/name/artist blob) to use as a **source pool** instead of the whole library.
- `~/vibe-playlists/profile.py` — taste-profile stats (see reverse-Wrapped below).
- `~/vibe-playlists/snapshot.sh "Name"` — save a playlist's current tracks as the diff
  baseline (`snapshots/<slug>.tsv`). Run after building or after absorbing edits.
- `~/vibe-playlists/diff.sh "Name"` — show what changed vs the last snapshot
  (added / removed / reordered). Read-only; does not move the baseline.
- `~/vibe-playlists/learn.sh "Name"` — absorb manual edits: log adds/cuts to
  `feedback.tsv`, flag added artists that still need tags, then re-snapshot.

## Feedback loop (when the user edits a playlist by hand)
When the user says they tweaked a playlist and wants it checked ("I cleaned up Modern
Indie, see what I changed"):
1. Run `learn.sh "Name"`. It prints the diff, appends rows to `feedback.tsv`
   (`date  playlist  action  artist  name`), flags any added artists missing from
   `artist_tags.tsv`, and re-snapshots.
2. For each `NEEDS TAG → artist`, derive a tag row and append to `artist_tags.tsv`.
3. Treat `feedback.tsv` as taste signal in future builds: **`removed` from a vibe =
   avoid that song (and lean away from its artist) for that vibe; `added` = it belongs.**
   Check it before curating a similar playlist.
- Snapshots are captured **on demand** (at build time and when checking edits) — there is
  no background watcher, so always diff/learn against the most recent snapshot.

## Sources & filters
- Default source is the whole library (`library.tsv`). If the user names a playlist as the
  source ("a chill version of my Gym playlist", "mellow cuts from my Shazams"), pull that
  pool with `playlist_tracks.sh`, join its persistent IDs to `library.tsv` (year/dateAdded)
  and artists to `artist_tags.tsv`, then filter/curate as usual.
- **Filters**: `year` column = release year; `dateAdded` = when added (use for "recent" /
  era windows); plus derived_genre / region / energy / mood. Combine freely.

## Taste note (important)
The user tired of hip-hop/rap ~2021; raw track/play counts over-represent that old era.
Their **current** taste (by `dateAdded` 2023+) leans Electronic/Dance, R&B/Soul, UK rap,
Afro, indie, Latin. Do NOT default to US hip-hop. For "favorites/nostalgia" use lifetime
`plays`; for "what I'm into now" prefer recently-added tracks. See memory `music-taste-shift`.

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
