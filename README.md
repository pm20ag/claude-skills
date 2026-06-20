# claude-skills

A personal marketplace of Claude Code skills. Add it once, then install whichever skills you want.

## Install (Claude Code)
```
/plugin marketplace add pm20ag/claude-skills
/plugin install vibe-playlist
```
New skills you add to this repo show up in the marketplace automatically after you push.

> Manifest fields have been verified against the current Claude Code plugin docs.
> Licensed under [MIT](./LICENSE).

## Skills

| Plugin | What it does | Platform |
|--------|--------------|----------|
| [vibe-playlist](./vibe-playlist) | Build Apple Music playlists from your own library by vibe; reverse-Wrapped taste profiler | macOS |

## Layout
```
claude-skills/
├── .claude-plugin/marketplace.json   ← lists every plugin (repo = marketplace)
├── vibe-playlist/                    ← a self-contained plugin
│   ├── .claude-plugin/plugin.json
│   ├── skills/vibe-playlist/SKILL.md
│   ├── scripts/…
│   ├── install.sh                    ← also usable standalone (portable route)
│   └── README.md
├── _template-skill/                  ← copy this to start a new skill
└── ADDING_SKILLS.md
```

Each plugin is fully self-contained (carries its own scripts/data), so any skill can be
split back into its own repo later with no rewiring. See [ADDING_SKILLS.md](./ADDING_SKILLS.md)
to add the next one.
