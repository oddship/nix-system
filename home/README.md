# Home-Manager Modules Documentation

This directory contains modular home-manager configurations for user environments. These modules provide user-specific settings, dotfiles, and program configurations.

## Directory Structure

```
home/
├── profiles/       # Complete user environment profiles
│   └── desktop.nix # Desktop user profile
└── programs/       # Individual program configurations
    ├── shell.nix      # Shell environment (zsh, direnv, fzf)
    ├── terminal.nix   # Terminal emulators (kitty, ghostty, rofi)
    ├── git.nix        # Git configuration
    └── neovim.nix     # Neovim configuration
```

## Profile Modules (`profiles/`)

### `desktop.nix`
Complete desktop user environment profile.

**Imports:**
- All program modules from `programs/`

**Provides:**
- User home directory configuration
- Desktop packages (btop, htop, development tools)
- GNOME extensions and dconf settings
- XDG mime associations
- Autostart applications (syncthingtray, ktailctl)

**Key Features:**
- GNOME shell customization (extensions, keybindings, favorites)
- Dark theme preference
- Custom wallpaper
- Workspace configuration
- Clipboard history integration

**Usage:**
```nix
{
  home-manager.users.username = {
    imports = [ ./home/profiles/desktop.nix ];
    _module.args = {
      gitConfigExtra = "/path/to/git/config";
    };
  };
}
```

## Program Modules (`programs/`)

### `shell.nix`
Shell environment configuration.

**Provides:**
- **Zsh**: Oh-My-Zsh with git, docker, dotenv plugins
- **Aliases**: Enhanced ls (eza), cd (zoxide), sudo with env preservation
- **Zoxide**: Smart directory navigation
- **Direnv**: Automatic environment loading with nix-direnv
- **Fzf**: Fuzzy finder with zsh integration

**Shell Customizations:**
- PATH includes `$HOME/go/bin`
- Default editor set to vim
- fnm (Fast Node Manager) integration
- Ghostty terminal compatibility fix

### `terminal.nix`
Terminal emulator configurations.

**Provides:**
- **Kitty**: Basic terminal emulator setup
- **Ghostty**: Modern terminal with zsh integration
- **Rofi**: Application launcher (Wayland version)

### `git.nix`
Git version control configuration.

**Provides:**
- User name and email settings
- Support for external git configuration includes
- Basic git setup

**Usage with External Config:**
```nix
{
  _module.args = {
    gitConfigExtra = config.age.secrets.git-config-extra.path;
  };
}
```

### `neovim.nix`
Comprehensive Neovim configuration for development.

**Provides:**
- **Full LSP support**: Nix, Python, TypeScript, Go, Rust, Bash, JSON, YAML
- **GitHub Copilot integration**: AI-powered code completion
- **Auto-completion**: nvim-cmp with snippets support
- **Syntax highlighting**: Treesitter for multiple languages
- **File navigation**: Telescope fuzzy finder, nvim-tree file explorer
- **Git integration**: gitsigns, fugitive
- **Modern UI**: Tokyo Night theme, lualine status bar, bufferline tabs
- **Development tools**: auto-pairs, comments, indentation guides, terminal

### `tmux.nix`
Terminal multiplexer configuration.

**Key Bindings:**
- **Prefix**: `Ctrl+a` (instead of default `Ctrl+b`)
- **Split panes**: `|` (horizontal), `-` (vertical)
- **Navigate panes**: `Alt+arrows` (no prefix needed)
- **Resize panes**: `Ctrl+arrows` (with prefix)
- **Switch windows**: `Shift+arrows` (no prefix needed)
- **Copy mode**: `v` (select), `y` (copy), `r` (rectangle mode)
- **Reload config**: `prefix + r`

**Shell Aliases:**
```bash
tm          # tmux
tma <name>  # tmux attach-session -t <name>
tmn <name>  # tmux new-session -s <name>
tml         # tmux list-sessions
tmk <name>  # tmux kill-session -t <name>
tms         # tmux-session (interactive session manager)
tmd         # tmux-session --dev (create dev session)
```

**Shell Functions:**
- `tmux-dev`: Create development session for current directory
- `tmux-attach`: Attach to session with fzf selection

**Session Manager:**
The `tmux-session` script provides an interactive session manager:

- **`tms`**: Interactive menu with options:
  - Attach to existing session
  - Create new session
  - Create development session
  - Kill session
  - Show session info
  - List all sessions

- **`tmd`**: Directly creates a development session for current directory:
  - Uses current directory name as session name
  - Creates 3-pane layout:
    - Left pane: Opens `nvim` automatically
    - Top right pane: Terminal in current directory
    - Bottom right pane: Terminal in current directory
  - Selects the nvim pane and attaches to the session

## Integration with NixOS

Home-manager can be integrated with NixOS in two ways:

### As a NixOS Module (Recommended)
```nix
{
  home-manager = {
    backupFileExtension = "bak";
    users.username = {
      imports = [ ./home/profiles/desktop.nix ];
    };
  };
}
```

### Standalone
```bash
home-manager switch --flake .#username@hostname
```

## Module Arguments

Some modules accept arguments that can be passed from the host configuration:

- `gitConfigExtra`: Path to additional git configuration file
- `inputs`: Flake inputs for accessing external packages
- `pkgs`: Nixpkgs instance

## Customization Guide

### Adding New Programs

1. Create a new file in `programs/`:
```nix
{ config, lib, pkgs, ... }:
{
  programs.myprogram = {
    enable = true;
    # ... configuration
  };
}
```

2. Import it in the relevant profile:
```nix
imports = [
  ../programs/myprogram.nix
];
```

### Creating New Profiles

1. Create a new profile in `profiles/`:
```nix
{ inputs, pkgs, ... }:
{
  imports = [
    # Import needed program modules
  ];
  
  home = {
    username = "myuser";
    homeDirectory = "/home/myuser";
    stateVersion = "24.11";
    packages = with pkgs; [
      # Profile-specific packages
    ];
  };
}
```

## Best Practices

1. **Modularity**: Keep program configurations separate and focused
2. **Reusability**: Design modules to be usable across different profiles
3. **Documentation**: Document module options and usage
4. **Version Control**: Specify `stateVersion` to ensure compatibility
5. **Backup**: Use `backupFileExtension` to handle file conflicts

## Common Issues

### File Conflicts
If home-manager encounters existing files, it creates `.bak` backups. Review and remove these after verifying the new configuration.

### Autostart Applications
Some applications may require manual intervention on first boot. The autostart configuration handles most cases but check application-specific requirements.

### Environment Variables
Shell environment variables set in `programs.zsh.initContent` are only available in interactive shells. For system-wide variables, use NixOS configuration.