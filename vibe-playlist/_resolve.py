#!/usr/bin/env python3
# Resolve a playlist name to its persistent ID by EXACT (byte) match.
# Reads "persistentID\tname" lines on stdin; prints the matching ID (or nothing).
# Python compares the emoji bytes correctly, unlike AppleScript's `whose name is`.
import sys

target = sys.argv[1]
for line in sys.stdin:
    line = line.rstrip("\n")
    if not line:
        continue
    pid, _, name = line.partition("\t")
    if name == target:
        print(pid)
        break
