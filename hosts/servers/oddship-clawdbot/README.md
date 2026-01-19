# oddship-clawdbot Server

NixOS server on Hetzner Cloud running clawdbot AI gateway.

## Overview

- **Type**: Hetzner cpx11 (2 vCPU, 2GB RAM)
- **Cost**: ~$4/month
- **Location**: nbg1 (Nuremberg, Germany)
- **Purpose**: Clawdbot Discord gateway

## Architecture

```
oddship-clawdbot
├── NixOS 24.11
├── clawdbot-gateway (systemd user service via nix-clawdbot)
└── Channel: Discord (DM pairing for access control)
```

## Deployment

```bash
# Initial setup (run from nix-system root)
just clawdbot-setup

# Deploy updates
just clawdbot-deploy

# SSH access
ssh rhnvrm@$(just clawdbot-ip)
```

## Configuration

- **NixOS config**: `configuration.nix`
- **Disk layout**: `disko-config.nix` (LVM on ext4)
- **Home-manager**: `home/profiles/clawdbot.nix`
- **Secrets**: `secrets/discord-bot-token.age`

## Clawdbot Management

```bash
# On the remote host:

# Health check
clawdbot doctor

# View logs
journalctl --user -u clawdbot-gateway -f

# List pending pairings
clawdbot pairing list discord

# Approve a user
clawdbot pairing approve discord <CODE>

# Check channel status
clawdbot channels status --probe
```

## Secrets

| Secret | Description |
|--------|-------------|
| `discord-bot-token.age` | Discord bot token from Developer Portal |

## Security

- SSH only (port 22)
- No Docker required
- DM pairing mode for access control
- Guild allowlist for server access
