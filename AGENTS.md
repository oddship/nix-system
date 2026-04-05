# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Configuration Management
- `just switch` - Build and switch to new configuration  
- `just build` - Build configuration without switching
- `just check` - Check configuration for errors
- `just fmt` - Format all nix files with nixfmt
- `just diff` - Show diff between current and new configuration
- `just test` - Test configuration in a VM
- `just debug` - Build and switch with verbose output

### Package and System Management
- `just update` - Update all flake inputs
- `just update <input>` - Update specific flake input
- `just search <query>` - Search for packages in nixpkgs
- `just clean` - Garbage collect old generations (7 days)
- `just clean-all` - Full cleanup (generations + build artifacts)
- `just rollback` - Rollback to previous generation

### Development Tools
- `just repl` - Start Nix REPL with flake
- `just new-module <category> <name>` - Create new module template
- `just new-script <name>` - Create new script template
- `just edit-script <name>` - Edit existing script
- `just list-scripts` - List available scripts

### Secrets Management
- `just secret edit <name>` - Edit encrypted secret with agenix
- `just secret list` - List all secrets
- `agenix -e secrets/<name>.age` - Edit specific secret directly

### Remote Deployment
- `just deploy <host> <target>` - Deploy to remote host
- `just init-host <host> <target>` - Initialize new host with nixos-anywhere

## Architecture

This is a modular, flake-based NixOS configuration with three main architectural layers:

### 1. Host Configurations (`hosts/`)
- **Desktop machines**: `hosts/desktop/` - Full desktop environments
- **Servers**: `hosts/servers/` - Minimal server configurations
- Each host imports relevant modules and sets host-specific options

### 2. Reusable Modules (`modules/`)
- **System modules** (`system/`): Core system configuration (common.nix, boot.nix, networking.nix)
- **Desktop modules** (`desktop/`): Desktop environments (gnome.nix)
- **Service modules** (`services/`): System services (openssh.nix, desktop.nix, development.nix)
- **User modules** (`users/`): User account management (rhnvrm.nix)
- **Package modules** (`packages/`): Package collections (desktop.nix, development.nix, scripts.nix)
- **Hardware modules** (`hardware/`): Hardware-specific configurations (laptop.nix)

### 3. Home-Manager Configurations (`home/`)
- **Profiles** (`profiles/`): Complete user environment profiles (desktop.nix)
- **Programs** (`programs/`): Individual program configurations (shell.nix, terminal.nix, git.nix, development.nix, tmux.nix)

### Key Technologies
- **Nix Flakes**: Reproducible builds with locked dependencies
- **Disko**: Declarative disk partitioning
- **Agenix**: Encrypted secrets management
- **Home-Manager**: User environment management
- **Just**: Task automation (replaces traditional Makefiles)

## Module System

All modules follow NixOS conventions with `options` and `config` sections:
- Use `lib.mkEnableOption` for feature toggles
- Use `lib.mkDefault` for overridable defaults
- Gate functionality behind enable options for flexibility

Example module structure:
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.category.name;
in
{
  options.category.name = {
    enable = lib.mkEnableOption "description";
  };
  
  config = lib.mkIf cfg.enable {
    # Configuration
  };
}
```

## Common Patterns

### Adding New Host
1. Create directory in `hosts/desktop/` or `hosts/servers/`
2. Add `configuration.nix`, `hardware-configuration.nix`, optional `disko-config.nix`
3. Add to `flake.nix` outputs
4. Import relevant modules and configure options

### Adding New Module
1. Use `just new-module <category> <name>` to create template
2. Implement options and configuration
3. Import module in relevant host configurations
4. Enable with `category.name.enable = true;`

### Managing Secrets
- Store in `secrets/` directory as `.age` files
- Reference with `config.age.secrets.secret-name.path`
- Edit with `just secret edit <name>`

## Current Hosts

- **oddship-thinkpad-x1**: Primary desktop workstation (GNOME, development tools)
- **oddship-ux303**: Laptop server configuration (WiFi enabled)
- **oddship-beagle**: Basic server configuration

## Custom Scripts

Located in `scripts/` directory, built and installed system-wide:
- `kill-port` - Interactive process killer by port using fzf
- `clipfile` - Copy file contents to system clipboard
- `tmux-session` - Interactive tmux session manager with development session support
- `aicat` - AI-friendly file concatenation tool for analysis

Scripts are managed by `modules/packages/scripts.nix` and available after rebuild.

## Neovim Git Code Review Features

Enhanced git workflow with professional code review tools:

### GitSigns (Enhanced)
- **Inline blame**: Shows author, date, and commit message on each line
- **Hunk navigation**: `]c` / `[c` to jump between changes
- **Hunk staging**: `<leader>hs` (stage), `<leader>hr` (reset)
- **Preview hunks**: `<leader>hp` for inline diff preview
- **Blame toggle**: `<leader>tb` to toggle line blame on/off

### DiffView
- **Professional diff viewer**: `<leader>gd` opens side-by-side diffs
- **File history**: `<leader>gh` shows complete file history
- **Current file history**: `<leader>gH` for current buffer only
- **Conflict resolution**: `[x` / `]x` navigate conflicts, `<leader>co/ct/cb/ca` choose sides

### Neogit
- **Modern git interface**: `<leader>gs` opens full git status with staging
- **Integrated with diffview**: Seamless diff viewing from status
- **Branch management**: Visual branch switching and management
- **Commit workflow**: Built-in commit message editor with validation

### Octo (GitHub Integration)
- **PR management**: `<leader>gp` lists and manages pull requests
- **Issue tracking**: `<leader>gi` lists and manages GitHub issues
- **Review workflow**: Review PRs directly in neovim with comments and approvals
- **GitHub API**: Full GitHub integration without leaving editor

### Git Conflict Resolution
- **Enhanced conflict highlighting**: Clear visual distinction between conflict sections
- **Smart conflict navigation**: Jump between conflicts with ease
- **Quick resolution**: Built-in commands for choosing conflict sides

## Tmux Configuration

Custom tmux setup with session management:
- **Prefix**: `Ctrl+a` (instead of default `Ctrl+b`)
- **Split panes**: `|` (horizontal), `-` (vertical)
- **Navigate panes**: `Alt+arrows` (no prefix needed)
- **Aliases**: `tms` (session manager), `tmd` (dev session)
- **Development sessions**: 3-pane layout with nvim + 2 terminals

## Flake Structure

The `flake.nix` defines:
- **Inputs**: nixpkgs, home-manager, disko, agenix, etc.
- **Outputs**: NixOS configurations for each host
- **Home-Manager**: Integrated as NixOS module
- **Overlays**: Custom package modifications

## Development Workflow

1. Make changes to modules or host configurations
2. Run `just check` to validate syntax
3. Run `just build` to test build without switching
4. Run `just switch` to apply changes
5. Use `just fmt` to format code before committing
6. Use `just rollback` if issues occur