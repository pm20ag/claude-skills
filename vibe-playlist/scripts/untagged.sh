#!/bin/bash
# List library artists that don't yet have a row in artist_tags.tsv,
# sorted by how many tracks they have (highest payoff first).
# Usage: ./untagged.sh [N]   (N = show top N, default 40)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
N="${1:-40}"

# tagged artist names (skip header)
tail -n +2 "$DIR/artist_tags.tsv" | cut -f1 | sort -u > /tmp/_tagged.txt
# library artists by track count, minus the tagged ones
awk -F'\t' 'NR>1{print $3}' "$DIR/library.tsv" | sort | uniq -c | sort -nr \
  | sed 's/^ *//' \
  | while read -r count artist; do
      grep -Fxq "$artist" /tmp/_tagged.txt || printf '%s\t%s\n' "$count" "$artist"
    done | head -"$N"