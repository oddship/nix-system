# Claude Skills

This directory contains Claude Code skills that are managed declaratively through home-manager.

## Overview

Skills are specialized knowledge packages that extend Claude's capabilities for specific domains or workflows. Instead of distributing skills as zip files, we manage them in this git repository and use home-manager to symlink them to `~/.claude/skills/`.

## Directory Structure

```
skills/
├── README.md                    # This file
└── tmux-orchestrator/          # Example skill
    ├── SKILL.md                # Main skill instructions
    ├── references/             # Reference documentation
    │   └── keybindings.md
    └── scripts/                # Helper scripts
        └── session-template.sh
```

## How It Works

Skills in this directory are automatically symlinked to `~/.claude/skills/` via home-manager configuration.

**Configuration**: `home/programs/claude-skills.nix`

```nix
home.file.".claude/skills/tmux-orchestrator" = {
  source = ../../skills/tmux-orchestrator;
  recursive = true;
};
```

**Deployment**: Run `just switch` to rebuild the system and deploy skills.

## Benefits

- **Version controlled**: Skills tracked in git alongside system config
- **Declarative**: Managed through nix configuration
- **Automatic deployment**: Symlinks created on system rebuild
- **Co-located with configs**: Skills live near related configurations (e.g., tmux skill near tmux.nix)

## Adding New Skills

### 1. Create Skill Directory

```bash
mkdir -p skills/my-skill/{references,scripts}
```

### 2. Create SKILL.md

Every skill requires a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: my-skill
description: Clear description of what the skill does and when to use it
---

# My Skill

## Overview
[Skill content here]
```

See `tmux-orchestrator/SKILL.md` for a complete example.

### 3. Add to home-manager

Edit `home/programs/claude-skills.nix`:

```nix
home.file.".claude/skills/my-skill" = {
  source = ../../skills/my-skill;
  recursive = true;
};
```

### 4. Deploy

```bash
cd ~/nix-system
git add skills/my-skill home/programs/claude-skills.nix
just switch
```

The skill will be available at `~/.claude/skills/my-skill/`.

## Skill Structure

A complete skill may include:

### SKILL.md (required)

The main skill file with:
- **YAML frontmatter**: `name` and `description` (required)
- **Markdown content**: Instructions, patterns, and workflows

### references/ (optional)

Documentation loaded into context as needed:
- API references
- Configuration details
- Database schemas
- Domain knowledge

**Example**: `tmux-orchestrator/references/keybindings.md` contains the full tmux configuration reference.

### scripts/ (optional)

Executable code for deterministic operations:
- Helper scripts
- Templates
- Utilities

**Example**: `tmux-orchestrator/scripts/session-template.sh` demonstrates session creation patterns.

### assets/ (optional)

Files used in output (not loaded into context):
- Templates
- Images
- Boilerplate code
- Fonts

## Existing Skills

### tmux-orchestrator

Teaches agents how to create and manage tmux sessions programmatically via the Bash tool.

**Use when**: Working on multi-component projects (backend/frontend), microservices, or any complex tmux session layouts.

**References**: Includes custom keybindings extracted from `home/programs/tmux.nix`.

**Location**: `skills/tmux-orchestrator/`

## Maintenance

### Updating Skills

1. Edit files in `skills/<skill-name>/`
2. Run `just switch` to deploy changes
3. Commit to git

### Syncing with Configs

When updating related configs (e.g., `home/programs/tmux.nix`):
- Update corresponding skill references (e.g., `skills/tmux-orchestrator/references/keybindings.md`)
- Commit both changes together to keep them in sync

### Removing Skills

1. Remove directory: `rm -rf skills/<skill-name>/`
2. Remove entry from `home/programs/claude-skills.nix`
3. Run `just switch`
4. Commit changes

## Resources

- [Claude Skills Documentation](https://github.com/anthropics/anthropic-agent-skills)
- Creating skills: Use the skill-creator skill in Claude Code
- Packaging: Not needed for personal skills managed via nix

## Notes

- Skills are deployed through the nix store, so changes require a rebuild
- The `.claude/skills/` symlinks are managed by home-manager
- Each skill is independent and can be updated individually
- Skills persist across system rebuilds and reboots
