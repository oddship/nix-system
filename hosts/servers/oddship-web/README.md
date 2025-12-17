# oddship-web Server

NixOS server on Hetzner Cloud for hosting oddship.net.

## Quick Start

```bash
# Enter dev shell (provides tofu, agenix, jq)
nix develop

# Full setup: generates host key, configures secrets, provisions server
just server-setup

# Or step by step:
just server-init-key      # Generate SSH host key in terraform
just server-setup-secrets # Update secrets.nix + rekey
just server-provision     # Create server + install NixOS
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Cloudflare (proxied)                     │
│                  oddship.net → 167.x.x.x                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 Hetzner Cloud (cpx11)                       │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    NixOS 26.05                        │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │  │
│  │  │   Caddy     │  │   agenix    │  │   systemd    │  │  │
│  │  │  (HTTPS)    │  │  (secrets)  │  │  (services)  │  │  │
│  │  └─────────────┘  └─────────────┘  └──────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│  Disk: LVM on ext4 (avoids partition label timing issues)   │
└─────────────────────────────────────────────────────────────┘
```

## Files

| File | Purpose |
|------|---------|
| `configuration.nix` | NixOS system config (users, services, secrets) |
| `disko-config.nix` | Disk partitioning (LVM layout) |
| `../../terraform/` | Infrastructure as code (Hetzner + Cloudflare) |
| `../../secrets/secrets.nix` | agenix public keys |

## Key Decisions

**LVM instead of direct ext4/btrfs**: Avoids boot failures from partition label timing issues. See disko issues #736, #739.

**Pre-generated SSH host key**: Terraform generates the server's SSH host key before provisioning. This lets us encrypt agenix secrets for the server before it exists.

**Cloudflare proxy**: Orange-cloud enabled for DDoS protection and IP hiding. Uses DNS-01 challenge for Let's Encrypt certificates.

## Common Tasks

```bash
# Deploy config changes
just deploy oddship-web

# SSH to server
ssh rhnvrm@$(just tofu-ip)

# View server IP
just tofu-ip

# Destroy and recreate
just tofu-destroy
just server-setup
```

## Secrets

The server needs access to `cloudflare-api-token.age` for Caddy DNS-01 challenges. The host key is added to `secrets/secrets.nix` as `oddship_web`.

To re-key secrets after host key changes:
```bash
cd secrets && agenix -r
```
