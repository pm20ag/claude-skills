#!/usr/bin/env python3
# Transpose the column-joined export blob into a TSV.
# Usage: transpose.py <blob_file> <out_tsv>
import sys

RS = chr(30)
TAB = chr(9)

blob_path, out_path = sys.argv[1], sys.argv[2]
with open(blob_path, encoding="utf-8") as f:
    blob = f.read()

cols = blob.split(RS)
rows = [c.split(TAB) for c in cols]
n = min(len(r) for r in rows)
header = ["persistentID", "name", "artist", "album", "genre", "year", "plays", "durationSec", "dateAdded"]

with open(out_path, "w", encoding="utf-8") as f:
    f.write("\t".join(header) + "\n")
    for i in range(n):
        rec = [rows[c][i].replace("\t", " ").replace("\n", " ") for c in range(len(rows))]
        f.write("\t".join(rec) + "\n")

print(f"Wrote {n} tracks to {out_path}")
