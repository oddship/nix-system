# Personal Shell Scripts

This directory contains custom shell scripts that are built and installed system-wide via Nix.

## Available Scripts

### kill-port
Interactive process killer by port using fzf.

**Usage:**
```bash
kill-port
```

**Features:**
- Lists all processes listening on TCP ports
- Fuzzy search with fzf for easy selection
- Shows detailed process information before killing
- Confirmation prompt for safety
- Uses `kill -9` for force termination

**Dependencies:** lsof, fzf, awk, ps, sudo

### clipfile
Copy file contents to system clipboard with cross-platform support.

**Usage:**
```bash
clipfile [OPTIONS] FILE
```

**Options:**
- `-h, --help`: Show help message
- `-v, --verbose`: Show verbose output
- `-n, --no-newline`: Remove trailing newline from output

**Features:**
- Auto-detects available clipboard backend
- Supports X11 (xclip, xsel), Wayland (wl-clipboard), and macOS (pbcopy)
- File validation and error handling
- Verbose mode for detailed feedback
- Option to strip trailing newlines

**Dependencies:** xclip OR xsel OR wl-clipboard OR pbcopy (platform-dependent)

## Adding New Scripts

1. Add your `.sh` script to this directory
2. Make sure it has a proper shebang (`#!/usr/bin/env bash`)
3. The script will be automatically built and installed as `script-name` (without .sh extension)
4. Dependencies should be added to the `scripts.nix` module if needed

## Module Integration

Scripts are managed by the `modules/packages/scripts.nix` module:

- Enable with `packages.scripts.enable = true;` in your host configuration
- Scripts are wrapped with necessary dependencies in PATH
- Available system-wide after rebuild

## Script Guidelines

- Use `set -euo pipefail` for robust error handling
- Include clear documentation and usage examples
- Handle user input validation and edge cases
- Provide meaningful error messages
- Use confirmation prompts for destructive operations