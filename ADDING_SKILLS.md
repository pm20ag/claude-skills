# Adding a skill

Each skill is its own self-contained plugin folder in this repo. To add one:

1. **Copy the template** to a new plugin folder named after your skill:
   ```bash
   cp -R _template-skill my-new-skill
   mv my-new-skill/skills/SKILL_NAME my-new-skill/skills/my-new-skill
   ```

2. **Fill in the plugin manifest** — `my-new-skill/.claude-plugin/plugin.json`:
   set `name` (must match the folder), `version`, `description`, `author`.

3. **Write the skill** — `my-new-skill/skills/my-new-skill/SKILL.md`. The frontmatter
   `name` must match; the `description` is what triggers the skill, so make it specific.

4. **Add any tooling** under `my-new-skill/scripts/`. Namespace its data dir as
   `~/my-new-skill/` so it can't collide with other skills.

5. **Register it in the marketplace** — add an entry to `.claude-plugin/marketplace.json`:
   ```json
   { "name": "my-new-skill", "source": "./my-new-skill", "description": "…" }
   ```

6. **Commit and push.** Users who've added the marketplace can now `/plugin install my-new-skill`.

## Conventions
- One plugin = one skill folder (Option 1: independent install + versioning).
- Keep each plugin self-contained — no shared code across plugin folders, so any one can be
  extracted to its own repo later.
- Bump the plugin's `version` in its `plugin.json` when you change it.
- If a skill needs first-run setup, document it in the skill's own `SKILL.md` (see
  vibe-playlist's "Setup (first run)" section for the pattern).
