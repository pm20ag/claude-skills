-- Exports the Apple Music library to a column-joined blob on stdout.
-- Columns are separated by RecordSep (ASCII 30); within a column, rows are
-- joined by Tab (ASCII 9). A python post-step transposes this into a TSV.
-- Done column-wise because bulk property reads are fast and avoid per-track
-- round trips (and AppleScript O(n^2) line concatenation).

set tabChar to (character id 9)
set recSep to (character id 30)

tell application "Music"
	set lib to library playlist 1
	set ids to persistent ID of every track of lib
	set nms to name of every track of lib
	set ars to artist of every track of lib
	set als to album of every track of lib
	set gns to genre of every track of lib
	set yrs to year of every track of lib
	set pcs to played count of every track of lib
	set durs to duration of every track of lib
	set das to date added of every track of lib
end tell

set AppleScript's text item delimiters to tabChar
set out to (ids as text) & recSep & (nms as text) & recSep & (ars as text) & recSep & (als as text) & recSep & (gns as text) & recSep & (yrs as text) & recSep & (pcs as text) & recSep & (durs as text) & recSep & (das as text)
set AppleScript's text item delimiters to ""
return out
