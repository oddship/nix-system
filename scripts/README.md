# scripts

These are personal shell helpers that get wrapped into the system when
`packages.scripts.enable = true;` is enabled.

The wrapper module is `modules/packages/scripts.nix`. It installs the commands
without the `.sh` suffix and makes sure the dependencies declared there are on
`PATH`.

## Current commands

| Command | Purpose |
| --- | --- |
| `aicat` | Concatenate multiple files into one markdown document with AI-friendly section headers. |
| `clipfile` | Copy a file's contents to the clipboard, with backend detection for Wayland/X11/macOS. |
| `get-hetzner-token` | Decrypt the Hetzner API token from agenix-managed secrets for infra scripts. |
| `git-worktree-search` | Fuzzy-pick a git worktree from the inbox worktree directory. |
| `kill-port` | Find a listening TCP port and kill the owning process after confirmation. |
| `kill-process` | Fuzzy-pick and kill a process by name. |
| `mdview` | Render a markdown file to temporary HTML with pandoc and open it in a browser. |
| `setup-chrome-mcp` | Start Chromium with remote debugging and write a `chrome-devtools` entry into `.mcp.json`. |
| `tmux-session` | Interactive tmux session manager with a simple "dev layout" path. |
| `update-llm-tools` | Update globally installed Node-based LLM CLIs. |

## Notes on a few repo-specific helpers

### `get-hetzner-token`

Used by the infra recipes in the root `justfile`. It expects the agenix secret
files to exist locally and uses `rage` plus the local SSH identity to decrypt
the token.

### `git-worktree-search`

Hard-coded to search under:

```text
$HOME/Documents/Code/inbox/git-worktrees
```

That is intentional. It is a personal helper, not a general-purpose worktree
browser.

### `tmux-session`

This is the fast path for "open a dev session for the current repo". The `--dev`
mode opens a 3-pane layout with Neovim in the first pane and two extra shells.

## Adding or changing scripts

1. Edit or add `scripts/*.sh`
2. If the command needs extra runtime dependencies, update
   `modules/packages/scripts.nix`
3. rebuild the system so the wrapped command is refreshed

Most of these are deliberately small and personal. If a script starts needing
real configuration or portability work, it should probably become something more
structured than a shell one-off.
