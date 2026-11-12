#!/usr/bin/env python3
# Diff a saved playlist snapshot against the live state.
# Usage: _diff.py <snapshot.tsv> <live.tsv>
# Each file: persistentID  name  artist  (no header). Compares by persistentID.
import sys

def load(path):
    order, by_id = [], {}
    with open(path, encoding="utf-8") as f:
        for ln in f:
            p = ln.rstrip("\n").split("\t")
            if len(p) < 3:
                continue
            order.append(p[0])
            by_id[p[0]] = (p[1], p[2])
    return order, by_id

snap_order, snap = load(sys.argv[1])
live_order, live = load(sys.argv[2])
snap_set, live_set = set(snap), set(live)

added = [i for i in live_order if i not in snap_set]
removed = [i for i in snap_order if i not in live_set]

# Reorder: among tracks present in both, did relative order change?
common_live = [i for i in live_order if i in snap_set]
common_snap = [i for i in snap_order if i in live_set]
reordered = (common_live != common_snap) and not added and not removed

def show(label, ids, src):
    print(f"\n{label} ({len(ids)}):")
    if not ids:
        print("  (none)")
    for i in ids:
        nm, ar = src[i]
        print(f"  {ar} — {nm}")

show("ADDED", added, live)
show("REMOVED", removed, snap)
if reordered:
    print("\nREORDERED: track order changed (same set of songs).")
elif not added and not removed:
    print("\nNo changes since last snapshot.")

# Machine-readable tail for the learning step (TAB: action, id, artist, name)
print("\n---FEEDBACK---")
for i in added:
    nm, ar = live[i]
    print(f"added\t{i}\t{ar}\t{nm}")
for i in removed:
    nm, ar = snap[i]
    print(f"removed\t{i}\t{ar}\t{nm}")
