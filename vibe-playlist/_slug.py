#!/usr/bin/env python3
# Codepoint-aware slug for snapshot filenames. ASCII alphanumerics are kept;
# any non-ASCII char (e.g. an emoji) contributes its hex codepoint, so emoji-only
# names like 🌙 and 🌑 produce DISTINCT slugs instead of both collapsing to empty.
import re
import sys

s = sys.argv[1]
base = re.sub(r'[^a-z0-9]+', '_', s.lower()).strip('_')
hexs = '_'.join(format(ord(c), 'x') for c in s if ord(c) > 127)
slug = '_'.join(x for x in (base, hexs) if x)[:60]
print(slug or 'playlist')
