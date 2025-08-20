# Zellij Terminal Multiplexer - Quick Reference

Zellij is a terminal workspace and multiplexer with batteries included. This guide covers the essential commands and keybindings for daily use.

## Getting Started

```bash
# Start zellij
zellij

# Start with a specific session name
zellij -s mysession

# List sessions
zellij ls

# Attach to existing session
zellij attach mysession

# Kill a session
zellij kill-session mysession
```

## Default Keybindings

### Mode System
Zellij uses a modal system. Press the key combination to enter a mode, then use the mode-specific keys:

- `Ctrl + p` - Enter **Pane** mode
- `Ctrl + t` - Enter **Tab** mode
- `Ctrl + r` - Enter **Resize** mode
- `Ctrl + s` - Enter **Scroll** mode
- `Ctrl + o` - Enter **Session** mode
- `Ctrl + h` - Enter **Help** mode

Press `Esc` or `Enter` to exit any mode and return to normal mode.

### Custom Keybindings (Configured in this setup)
These work directly from normal mode without entering a specific mode:

#### Pane Management
- `Alt + h/j/k/l` - Navigate between panes (vim-style)
- `Alt + n` - Create new pane
- `Alt + x` - Close focused pane

#### Tab Management  
- `Alt + t` - Create new tab
- `Alt + w` - Close current tab
- `Alt + 1-5` - Switch to tab 1-5

### Default Mode Keybindings

#### Pane Mode (`Ctrl + p`)
- `n` - New pane (split right)
- `d` - New pane (split down)
- `x` - Close focused pane
- `f` - Toggle pane fullscreen
- `z` - Toggle pane zoom
- `c` - Rename pane
- `h/j/k/l` - Navigate panes
- `H/J/K/L` - Move panes

#### Tab Mode (`Ctrl + t`)
- `n` - New tab
- `x` - Close tab
- `r` - Rename tab
- `h/l` - Switch between tabs
- `Tab` - Switch to next tab
- `1-9` - Go to tab number

#### Resize Mode (`Ctrl + r`)
- `h/j/k/l` - Resize panes
- `+/-` - Increase/decrease pane size
- `=` - Reset pane sizes

#### Scroll Mode (`Ctrl + s`)
- `j/k` or `↓/↑` - Scroll down/up
- `Ctrl + f/b` - Page down/up
- `d/u` - Half page down/up
- `g/G` - Go to top/bottom

#### Session Mode (`Ctrl + o`)
- `w` - Switch session
- `c` - Create new session
- `d` - Detach from session

## Layouts

Zellij supports predefined layouts for quick workspace setup:

```bash
# Use a specific layout
zellij --layout compact

# Common layouts
zellij --layout default    # Standard layout
zellij --layout strider    # File manager layout  
zellij --layout disable-status # No status bar
```

## Configuration

The configuration is located in your home-manager setup at:
- `home/programs/zellij.nix`

Key configuration options:
- `theme` - Color theme
- `mouse_mode` - Enable mouse support
- `pane_frames` - Show pane borders
- `keybinds` - Custom keybindings

## Tips and Tricks

1. **Mouse Support**: Click to focus panes, drag borders to resize
2. **Copy Mode**: Enter scroll mode (`Ctrl + s`) to copy text
3. **Floating Panes**: Use `Ctrl + p + w` for floating panes
4. **Search**: In scroll mode, use `/` to search, `n/N` for next/previous
5. **Command Palette**: Press `Ctrl + Shift + P` for command palette
6. **Quick Navigation**: Use the custom Alt+ keybindings for fastest navigation

## Session Management

```bash
# Background session that persists
zellij -d              # Start detached
zellij attach          # Attach to most recent

# Session with custom layout
zellij -l mylayout -s myproject

# Kill all sessions
zellij kill-all-sessions
```

## Comparison with tmux

| Feature | Zellij | tmux |
|---------|--------|------|
| Default UI | Rich, colorful | Minimal |
| Learning curve | Gentler | Steeper |  
| Mouse support | Built-in | Needs config |
| Plugins | WASM-based | Shell-based |
| Session persistence | Automatic | Manual setup |

## Troubleshooting

- **Terminal compatibility**: Works best with modern terminals
- **Key conflicts**: Check terminal emulator keybindings
- **Performance**: Lighter than tmux for most use cases
- **Plugin issues**: Check WASM plugin compatibility

## More Resources

- [Official Documentation](https://zellij.dev/documentation/)
- [Configuration Examples](https://github.com/zellij-org/zellij/tree/main/example)
- [Community Layouts](https://github.com/topics/zellij-config)