---
title: Claude + Zellij orchestration
description: How the repo's zellij helpers are meant to be used for AI-heavy terminal work.
---

# Claude + Zellij orchestration

This repo carries both tmux and zellij config. They are not trying to solve the
same problem.

- tmux is the more opinionated "open a dev workspace" tool
- zellij is the lighter session shell for hopping between repos and keeping
  long-running terminal contexts around

For Claude Code or other agent-heavy terminal workflows, zellij is usually the
faster default.

## What is actually configured

The relevant files are:

- `home/programs/zellij.nix`
- `home/programs/shell.nix`
- `home/programs/claude-skills.nix`

Current zellij defaults in this repo:

- Catppuccin Mocha theme
- session serialization enabled
- automatic layouts enabled
- `Alt+h/j/k/l` pane navigation
- `Alt+n` / `Alt+x` for pane create and close
- `Alt+t` / `Alt+w` for tab create and close
- `Alt+1..5` to jump tabs

Current shell helpers worth remembering:

- `za [name]` — attach to a session or create it if it does not exist
- `zf` — fuzzy session picker / quick session manager
- `zja`, `zjl`, `zjk` — thin aliases for attach, list, and kill
- `cdgw` — jump into a git worktree picked by `git-worktree-search`

## Practical patterns

### One repo, one session

From a repo root:

```bash
za
```

That uses the current directory name as the session name.

### Name a session explicitly

```bash
za nix-system
za blog
za docs
```

### Jump between sessions quickly

```bash
zf
```

That is the real day-to-day convenience command in this setup.

### Pair zellij with repo-local helper commands

A useful pattern is:

1. use `cdgw` to jump into a worktree
2. run `za` to create or attach to a session named after that worktree
3. keep the agent/tooling state inside that session instead of mixing repos

## Where tmux still fits better

tmux is still the better choice when you want the repo's pre-canned 3-pane dev
layout:

```bash
tmd
# or

tmux-session --dev
```

That path opens Neovim in the first pane and two extra shells beside it.

## Claude-specific notes

This repo also keeps personal Claude Code skills under `skills/`, and
`home/programs/claude-skills.nix` symlinks them into `~/.claude/skills/`.

Right now the relevant one is `tmux-orchestrator/`. It is still tmux-focused,
which matches the fact that tmux remains the more scripted option here.

For browser-assisted flows, `setup-chrome-mcp` is the helper that starts
Chromium with remote debugging and writes a `chrome-devtools` entry into a local
`.mcp.json`.
