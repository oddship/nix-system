# NixOS Modules Documentation

This directory contains reusable NixOS modules that provide a modular and maintainable configuration structure. Each module focuses on a specific aspect of the system configuration.

## Module Structure

All modules follow the standard NixOS module pattern:
```nix
{ config, lib, pkgs, ... }:
{
  options = { /* module options */ };
  config = { /* module configuration */ };
}
```

## Available Modules

### System Modules (`system/`)

#### `common.nix`
Core system configuration shared across all hosts.

**Provides:**
- Nix daemon settings (flakes, caching, substituters)
- Locale and timezone configuration (defaults to Asia/Kolkata)
- Console and shell settings
- Essential system packages (vim, wget, git, curl, htop, tmux, just, neovim)
- Firmware update support
- System version management

**Usage:**
```nix
imports = [ ./modules/system/common.nix ];
```

#### `boot.nix`
Boot loader configuration.

**Provides:**
- systemd-boot as default bootloader
- EFI variables support
- Common kernel modules for hardware support
- Clean /tmp on boot

**Usage:**
```nix
imports = [ ./modules/system/boot.nix ];
```

#### `networking.nix`
Network configuration and optimization.

**Provides:**
- NetworkManager for network management
- Modern firewall with nftables
- mDNS/Avahi for local network discovery
- systemd-resolved for DNS management
- TCP optimization settings

**Usage:**
```nix
imports = [ ./modules/system/networking.nix ];
```

### Desktop Modules (`desktop/`)

#### `gnome.nix`
GNOME desktop environment configuration.

**Options:**
- `desktop.gnome.enable` - Enable GNOME desktop environment

**Provides:**
- GNOME desktop with GDM display manager
- Minimal GNOME installation (removes many default apps)
- Font configuration (JetBrains Mono, Fira Code, Inter, etc.)
- Touchpad and Bluetooth support
- QMK keyboard support
- Essential GNOME utilities (tweaks, extension-manager)

**Usage:**
```nix
{
  imports = [ ./modules/desktop/gnome.nix ];
  desktop.gnome.enable = true;
}
```

### Service Modules (`services/`)

#### `openssh.nix`
OpenSSH server configuration.

**Provides:**
- SSH server with Ed25519 host keys
- Secure default configuration

**Usage:**
```nix
imports = [ ./modules/services/openssh.nix ];
```

#### `desktop.nix`
Desktop-specific services.

**Options:**
- `services.desktop.enable` - Enable desktop services

**Provides:**
- PipeWire audio system
- Tailscale and Netbird VPN
- Syncthing file synchronization

**Usage:**
```nix
{
  imports = [ ./modules/services/desktop.nix ];
  services.desktop.enable = true;
}
```

#### `development.nix`
Development environment services.

**Options:**
- `services.development.enable` - Enable development services
- `services.development.docker.enable` - Enable Docker
- `services.development.docker.storageDriver` - Docker storage driver (default: overlay2)
- `services.development.gaming.enable` - Enable Steam gaming support

**Provides:**
- Docker containerization with auto-prune
- Steam gaming platform with gamemode
- Development tool services (lorri, direnv)
- Android ADB support
- Wireshark network analysis

**Usage:**
```nix
{
  imports = [ ./modules/services/development.nix ];
  services.development = {
    enable = true;
    docker.enable = true;
    gaming.enable = true;
  };
}
```

### User Modules (`users/`)

#### `rhnvrm.nix`
User configuration for rhnvrm.

**Provides:**
- User account with zsh shell
- SSH authorized keys
- Essential user packages (git, neovim, firefox, vscode, zed)
- Wheel and networkmanager groups

**Usage:**
```nix
imports = [ ./modules/users/rhnvrm.nix ];
```

### Package Modules (`packages/`)

#### `desktop.nix`
Desktop application packages.

**Options:**
- `packages.desktop.enable` - Enable desktop applications

**Provides:**
- Browsers (Chromium, Zen Browser)
- Productivity apps (Obsidian, TickTick)
- Communication (Claude Desktop)
- Utilities (cliphist, syncthingtray, ktailctl)

**Usage:**
```nix
{
  imports = [ ./modules/packages/desktop.nix ];
  packages.desktop.enable = true;
}
```

#### `development.nix`
Development tool packages.

**Options:**
- `packages.development.enable` - Enable development tools

**Provides:**
- Terminal emulator (Kitty)
- Development tools (nomad, uv)
- Nix tooling (agenix)
- Network tools (nftables, iptables)
- Syncthing

**Usage:**
```nix
{
  imports = [ ./modules/packages/development.nix ];
  packages.development.enable = true;
}
```

### Hardware Modules (`hardware/`)

#### `laptop.nix`
Laptop-specific hardware configuration.

**Options:**
- `hardware.laptop.enable` - Enable laptop configuration

**Note:** Currently empty, reserved for future laptop-specific settings.

## Best Practices

1. **Use Enable Options**: Always gate module functionality behind enable options for flexibility
2. **Set Defaults**: Use `lib.mkDefault` for settings that hosts might want to override
3. **Document Options**: Clearly document what each module provides and its options
4. **Single Responsibility**: Each module should focus on one specific aspect
5. **Avoid Duplication**: Extract common patterns into shared modules

## Example Host Configuration

```nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    # Hardware
    ./hardware-configuration.nix
    
    # System modules
    ./modules/system/common.nix
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    
    # User management
    ./modules/users/rhnvrm.nix
    
    # Services
    ./modules/services/openssh.nix
    ./modules/services/desktop.nix
    ./modules/services/development.nix
    
    # Desktop environment
    ./modules/desktop/gnome.nix
    
    # Package collections
    ./modules/packages/desktop.nix
    ./modules/packages/development.nix
  ];
  
  # Enable desired features
  services.desktop.enable = true;
  services.development = {
    enable = true;
    docker.enable = true;
    gaming.enable = true;
  };
  desktop.gnome.enable = true;
  packages.desktop.enable = true;
  packages.development.enable = true;
  
  # Host-specific configuration
  networking.hostName = "my-hostname";
}
```