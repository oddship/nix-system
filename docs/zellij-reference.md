---
title: Zellij reference
description: Custom bindings and helper commands from the nix-system zellij setup.
---

# Zellij reference

This is the repo-specific reference for the current zellij setup, not a generic
copy of upstream docs.

See also [[Claude + Zellij orchestration]] for the workflow notes.

## Shell helpers

These come from `home/programs/shell.nix`.

| Command | What it does |
| --- | --- |
| `za [name]` | Attach to an existing session or create a new one. Defaults to the current directory name. |
| `zf` | Fuzzy session picker plus quick actions for create and kill. |
| `zja <name>` | Thin alias for `zellij attach`. |
| `zjl` | List sessions. |
| `zjk <name>` | Kill a session. |
| `zj` | Alias to `za`. |

## Custom bindings

These come from `home/programs/zellij.nix` and work directly in normal mode.

### Pane movement

- `Alt+h` — move focus left
- `Alt+j` — move focus down
- `Alt+k` — move focus up
- `Alt+l` — move focus right

### Pane and tab management

- `Alt+n` — new pane
- `Alt+x` — close focused pane
- `Alt+t` — new tab
- `Alt+w` — close current tab
- `Alt+1..5` — jump to tab 1 through 5

## Behavior toggles from this repo

The current Nix config also sets:

- `theme = "catppuccin-mocha"`
- `default_mode = "normal"`
- `mouse_mode = true`
- `pane_frames = true`
- `auto_layout = true`
- `session_serialization = true`
- `default_shell = "zsh"`

## Built-in modes worth remembering

Even with the custom shortcuts, the upstream mode system is still useful:

- `Ctrl+p` — pane mode
- `Ctrl+t` — tab mode
- `Ctrl+r` — resize mode
- `Ctrl+s` — scroll mode
- `Ctrl+o` — session mode
- `Ctrl+h` — help mode

That is usually enough to recover if you forget one of the custom bindings.
