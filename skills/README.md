# skills

This directory holds personal Claude Code skills that are deployed with Home
Manager.

They are kept in this repo because they describe and automate parts of this same
machine setup, so versioning them next to the related configs is simpler than
managing them out-of-band.

## Current state

Right now there is one skill:

- `tmux-orchestrator/`

It is deployed by `home/programs/claude-skills.nix`, which symlinks the skill to
`~/.claude/skills/tmux-orchestrator`.

## Layout

A skill directory can contain:

- `SKILL.md` — required instructions and frontmatter
- `references/` — optional supporting docs
- `scripts/` — optional helper scripts
- `assets/` — optional files used by generated output

## Adding a skill

1. create `skills/<name>/`
2. add a `SKILL.md`
3. add a matching `home.file` entry in `home/programs/claude-skills.nix`
4. rebuild with `just switch`

## Maintenance rule

If a skill is describing behavior from this repo, keep the skill and the source
config in sync in the same change. For example, if tmux keybindings change,
update both `home/programs/tmux.nix` and the tmux skill references together.
