# NixOS System Configuration

A modular, flake-based NixOS configuration for personal systems with declarative disk management, secrets handling, and home-manager integration.

## 🚀 Quick Start

```bash
# Build without switching
just build

# Build and switch to new configuration
just switch

# Update flake inputs
just update

# See all available commands
just --list
```

## 📁 Repository Structure

```
nix-system/
├── flake.nix           # Flake definition with inputs and outputs
├── flake.lock          # Locked flake dependencies
├── justfile            # Task automation (like Makefile)
├── modules/            # Reusable NixOS modules
│   ├── system/         # Core system configs
│   ├── desktop/        # Desktop environments
│   ├── services/       # System services
│   ├── users/          # User management
│   ├── packages/       # Package collections
│   └── hardware/       # Hardware profiles
├── home/               # Home-manager configs
│   ├── profiles/       # Complete user profiles
│   └── programs/       # Program configurations
├── hosts/              # Host-specific configs
│   ├── desktop/        # Desktop machines
│   └── servers/        # Server machines
└── secrets/            # Encrypted secrets (agenix)
```

## 🖥️ Hosts

| Host | Type | Description |
|------|------|-------------|
| `oddship-thinkpad-x1` | Desktop | Primary workstation with GNOME, development tools |
| `oddship-ux303` | Server | Laptop running as server, WiFi enabled |
| `oddship-beagle` | Server | Basic server configuration |

## 🔧 Key Features

- **Modular Design**: Reusable modules for easy configuration composition
- **Flakes**: Reproducible builds with locked dependencies
- **Disko**: Declarative disk partitioning
- **Agenix**: Encrypted secrets management
- **Home-Manager**: User environment management
- **Printing**: CUPS with Epson driver support and auto-discovery
- **Just**: Simple task automation

## 📦 Module System

### System Modules
- `common.nix` - Base system configuration
- `boot.nix` - Bootloader setup
- `networking.nix` - Network configuration

### Desktop Modules
- `gnome.nix` - GNOME desktop environment

### Service Modules
- `openssh.nix` - SSH server
- `desktop.nix` - Desktop services (audio, VPN, sync, printing)
- `development.nix` - Development tools (Docker, Steam)

### Package Modules
- `desktop.nix` - Desktop applications
- `development.nix` - Development tools

See [modules/README.md](modules/README.md) for detailed documentation.

## 🏠 Home-Manager

User-specific configurations including:
- Shell environment (zsh with oh-my-zsh)
- Terminal emulators (Kitty, Ghostty)
- Development tools (Neovim, Git)
- GNOME customization

See [home/README.md](home/README.md) for details.

## 🚀 Installation

### New Host

1. Boot NixOS installer
2. Partition disks according to your disko configuration
3. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/nix-system.git
   cd nix-system
   ```
4. Install:
   ```bash
   sudo nixos-install --flake .#hostname
   ```

### Remote Deployment

```bash
# Deploy to remote host
just deploy hostname root@ip-address

# Or use nixos-anywhere for fresh installation
nix run github:nix-community/nixos-anywhere -- --flake .#hostname --target-host root@ip-address
```

## 🔐 Secrets Management

Secrets are managed using [agenix](https://github.com/ryantm/agenix):

```bash
# Edit a secret
agenix -e secrets/secret-name.age

# Reference in configuration
config.age.secrets.secret-name.path
```

## 🛠️ Common Operations

### System Management
```bash
# Check configuration for errors
just check

# Show diff before switching
just diff

# Rollback to previous generation
just rollback

# Garbage collect old generations
just clean
```

### Development
```bash
# Open Nix REPL with flake
just repl

# Search for packages
just search package-name

# Format all Nix files
just fmt
```

### Printing
```bash
# Print a file
lp filename

# Check print queue
lpstat -o

# Open CUPS web interface
firefox http://localhost:631

# GUI printer configuration
system-config-printer
```

### Module Creation
```bash
# Create a new module
just new-module category name
```

## 📝 Adding a New Host

1. Create host directory:
   ```bash
   mkdir -p hosts/desktop/newhostname
   ```

2. Add configuration files:
   - `configuration.nix` - Main system config
   - `hardware-configuration.nix` - Hardware-specific config
   - `disko-config.nix` - Disk layout (if using disko)

3. Add to `flake.nix`:
   ```nix
   nixosConfigurations."newhostname" = nixpkgs.lib.nixosSystem {
     inherit system;
     specialArgs = { inherit inputs; };
     modules = commonModules ++ [
       ./hosts/desktop/newhostname/configuration.nix
     ];
   };
   ```

4. Import relevant modules in the host configuration

## 🤝 Contributing

1. Keep modules focused and single-purpose
2. Use `mkDefault` for overridable defaults
3. Document module options and usage
4. Test changes with `just check` before committing

## 📄 License

This configuration is personal but feel free to take inspiration from it.