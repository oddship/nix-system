# Clawdbot Infrastructure

OpenTofu configuration for the clawdbot server on Hetzner Cloud.
This is separate from oddship-web to isolate the infrastructure.

## Quick Start

```bash
# Enter nix dev shell
nix develop

# Initialize terraform
just clawdbot-init

# Generate host key (displays key for secrets.nix)
just clawdbot-init-key

# Update secrets/secrets.nix with the displayed key
# Then run: cd secrets && agenix -r

# Encrypt Discord bot token
just secret edit discord-bot-token

# Provision server
just clawdbot-provision

# Get server IP
just clawdbot-ip

# Deploy config updates
just clawdbot-deploy
```

## Resources Created

- **hcloud_server.clawdbot**: cpx11 VPS (~$4/mo)
- **hcloud_firewall.clawdbot**: SSH only (port 22)
- **hcloud_ssh_key.default**: Deploy SSH key
- **tls_private_key.host_ed25519**: Host key for agenix

## Post-Deployment Setup

After the server is provisioned, SSH in and configure Claude OAuth:

```bash
ssh rhnvrm@$(just clawdbot-ip)

# Configure Claude OAuth
claude setup-token
clawdbot models auth setup-token --provider anthropic

# Verify service
systemctl --user status clawdbot-gateway
clawdbot doctor

# Approve your Discord account
# 1. DM the bot from Discord
# 2. Copy the pairing code
clawdbot pairing approve discord <CODE>
```
