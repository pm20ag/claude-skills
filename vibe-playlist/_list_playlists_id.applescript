-- Emit "persistentID<TAB>name" for every user playlist (one per line).
-- Name matching is done downstream in Python (byte-exact), because AppleScript's
-- text comparison folds distinct emoji (e.g. 🌙 and 🌑) as equal.
set tabChar to (character id 9)
tell application "Music"
	set out to ""
	repeat with p in (get every user playlist)
		try
			set out to out & (persistent ID of p) & tabChar & (name of p) & linefeed
		end try
	end repeat
	return out
end tell
