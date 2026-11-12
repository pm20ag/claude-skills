#!/usr/bin/env python3
# Taste-profile stats for reverse-Wrapped. Prints region (all-time vs recent),
# energy spread, top moods, per-year breadth, and top artists (plays vs recent).
# Usage: python3 profile.py
import csv, re, os
from collections import Counter, defaultdict

DIR = os.path.dirname(os.path.abspath(__file__))
tags = {}
with open(os.path.join(DIR, 'artist_tags.tsv'), encoding='utf-8') as f:
    for r in csv.DictReader(f, delimiter='\t'):
        tags[r['artist']] = r
rows = list(csv.DictReader(open(os.path.join(DIR, 'library.tsv'), encoding='utf-8'), delimiter='\t'))

def yr(s):
    m = re.search(r'\b(19|20)\d\d\b', s)
    return int(m.group(0)) if m else None

def regbucket(reg):
    if reg.startswith('UK'): return 'UK'
    if reg.startswith('US'): return 'US'
    if reg.startswith(('NG', 'ZA')) or 'Afro' in reg: return 'Africa'
    if reg.startswith('CA'): return 'Canada'
    if reg.startswith(('PR', 'CO', 'MX')) or 'MX' in reg: return 'Latin'
    if reg.startswith('JM'): return 'Jamaica'
    return 'Other/Europe'

reg, reg_recent, moods, energy = Counter(), Counter(), Counter(), Counter()
for r in rows:
    t = tags.get(r['artist'])
    if not t: continue
    y = yr(r['dateAdded']); recent = y and y >= 2023
    reg[regbucket(t['region'])] += 1
    if recent: reg_recent[regbucket(t['region'])] += 1
    for m in t['mood'].split(','): moods[m.strip()] += 1
    try: energy[int(t['energy'])] += 1
    except ValueError: pass

def show(title, c, n=None):
    tot = sum(c.values()) or 1
    print(title)
    for k, v in c.most_common(n):
        print(f"  {k:14} {round(100*v/tot):>3}%  ({v})")

show("REGION (all-time tagged):", reg)
show("REGION (recent 2023+):", reg_recent)
print("ENERGY 1(chill)->5(hype):", {e: f"{round(100*energy.get(e,0)/(sum(energy.values()) or 1))}%" for e in range(1, 6)})
show("TOP MOODS:", moods, 15)

ua = defaultdict(set); tracks_per_yr = Counter()
plays = Counter(); recentadds = Counter()
for r in rows:
    y = yr(r['dateAdded'])
    if y: ua[y].add(r['artist']); tracks_per_yr[y] += 1
    try: plays[r['artist']] += int(r['plays'])
    except ValueError: pass
    if y and y >= 2024: recentadds[r['artist']] += 1
print("BREADTH (unique artists / tracks per year):")
for y in sorted(ua):
    if 2017 <= y <= 2026: print(f"  {y}: {len(ua[y])} artists / {tracks_per_yr[y]} tracks")
print("TOP ARTISTS by lifetime plays:", [a for a, _ in plays.most_common(10)])
print("TOP ARTISTS by recent adds (2024+):", [a for a, _ in recentadds.most_common(12)])
