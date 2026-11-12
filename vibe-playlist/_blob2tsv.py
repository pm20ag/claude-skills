#!/usr/bin/env python3
# Convert a playlist_tracks.sh RecordSep blob (stdin) into a TSV file.
# Usage: playlist_tracks.sh "Name" | _blob2tsv.py <out.tsv>
# Columns written: persistentID  name  artist   (no header)
# Prints the track count to stdout.
import sys

RS = chr(30)
TAB = chr(9)
out_path = sys.argv[1]

blob = sys.stdin.read().rstrip("\n")
cols = blob.split(RS)
if len(cols) < 3:
    sys.stderr.write("Could not read playlist (not found, or empty).\n")
    sys.exit(1)

ids = cols[0].split(TAB) if cols[0] else []
nms = cols[1].split(TAB) if cols[1] else []
ars = cols[2].split(TAB) if cols[2] else []
n = min(len(ids), len(nms), len(ars))

with open(out_path, "w", encoding="utf-8") as f:
    for i in range(n):
        f.write(f"{ids[i]}\t{nms[i]}\t{ars[i]}\n")
print(n)
