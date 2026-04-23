# home

Home Manager lives here. The shared user environment is split into a profile
layer and a set of per-program modules so the desktop host can reuse the same
editor, shell, terminal, and session-management setup without turning the host
files into a blob.

## Layout

```text
home/
├── profiles/
│   └── desktop.nix
└── programs/
    ├── claude-skills.nix
    ├── git.nix
    ├── lazygit.nix
    ├── neovim.nix
    ├── shell.nix
    ├── terminal.nix
    ├── tmux.nix
    └── zellij.nix
```

## Shared profile

`profiles/desktop.nix` is the main shared user profile.

It currently owns:

- Catppuccin theming
- common user packages
- desktop MIME defaults
- GNOME `dconf` settings
- wallpaper, favorites, and other shell UX choices
- autostart entries for desktop tools
- shared session variables such as `PINENTRY_PROGRAM`

The desktop profile imports these program modules:

- `shell.nix`
- `terminal.nix`
- `git.nix`
- `neovim.nix`
- `tmux.nix`
- `zellij.nix`
- `lazygit.nix`
- `claude-skills.nix`

## Program modules

### `programs/shell.nix`

Zsh plus the shell-level glue that makes the rest of the setup feel coherent.
This is where the repo-specific aliases and helpers live.

Current highlights:

- Oh My Zsh with `git`, `docker`, and `dotenv`
- `zoxide`, `fzf`, and `direnv` integration
- tmux aliases such as `tm`, `tms`, and `tmd`
- zellij helpers such as `za`, `zf`, `zjl`, and `zjk`
- `cdgw` for jumping to git worktrees found by `git-worktree-search`
- `TERM` compatibility fix for Ghostty on remote systems

### `programs/terminal.nix`

Terminal and launcher config:

- Kitty
- Ghostty
- Rofi

### `programs/git.nix`

Git defaults plus a few workflow niceties:

- base `programs.git` config
- optional include file via `gitConfigExtra`
- `delta` as diff viewer
- `wta` alias for creating worktrees under the inbox worktree directory

### `programs/neovim.nix`

The largest single user module in the repo. It provides the editor setup rather
than a tiny wrapper around distro defaults.

Current setup includes:

- LSP and completion
- Treesitter
- Telescope and Neo-tree
- Neogit, Diffview, Fugitive, and conflict helpers
- GitHub Copilot
- repo-specific extras such as `nvim-claudecode-mcp`

### `programs/tmux.nix`

The opinionated tmux setup used for heavier development sessions.

Key points:

- `Ctrl+a` prefix
- plugin set via `pkgs.tmuxPlugins`
- custom pane/window navigation bindings
- Ghostty-aware terminal handling

### `programs/zellij.nix`

A lighter terminal workspace option alongside tmux.

Current customizations include:

- Catppuccin Mocha theme
- `Alt+h/j/k/l` pane navigation
- `Alt+n` and `Alt+x` for pane create/close
- `Alt+t` and `Alt+w` for tab create/close
- `Alt+1..5` tab switching
- session serialization and automatic layout restoration

### `programs/lazygit.nix`

A themed lazygit config with Ghostty-based editor integration and custom key
choices that fit the rest of the shell/editor setup.

### `programs/claude-skills.nix`

Symlinks personal Claude Code skills from this repo into `~/.claude/skills/`.
Right now that is only `skills/tmux-orchestrator`, but this is the hook point
for adding more.

## Host overrides

Shared user config should stay in `home/`.

Host-specific changes belong in the host tree. Right now the main example is:

- `hosts/desktop/thinkpadx1/home.nix`

That file imports `home/profiles/desktop.nix` and keeps only the things that are
actually host-specific, such as extra packages or autostart plumbing.

## Working in this directory

A good rule of thumb:

- put reusable behavior in `home/programs/*.nix`
- collect stable defaults in `home/profiles/*.nix`
- keep host quirks in `hosts/.../home.nix`

That split has held up better than stuffing everything into a single giant home
module.
