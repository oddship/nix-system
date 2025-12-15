# justfile for NixOS system management
# https://github.com/casey/just

# Default recipe to display help
default:
    @just --list

# Set shell for recipes
set shell := ["bash", "-uc"]

# Variables
hostname := `hostname`
flake_path := justfile_directory()
current_system := if os() == "linux" { "x86_64-linux" } else { "unknown" }

# Colors for output
export BLUE := '\033[0;34m'
export GREEN := '\033[0;32m'
export YELLOW := '\033[1;33m'
export RED := '\033[0;31m'
export NC := '\033[0m' # No Color

# Show current system information
info:
    @echo -e "${BLUE}=== NixOS System Information ===${NC}"
    @echo "Hostname: {{hostname}}"
    @echo "Flake: {{flake_path}}"
    @echo "System: {{current_system}}"
    @echo "Generation: $(nixos-version --json | jq -r '.configurationRevision // "dirty"')"

# Build the system configuration without switching
build host=hostname:
    @echo -e "${BLUE}Building configuration for {{host}}...${NC}"
    sudo nixos-rebuild build --flake {{flake_path}}#{{host}}

# Build and switch to new configuration
switch host=hostname:
    @echo -e "${BLUE}Switching to new configuration for {{host}}...${NC}"
    sudo nixos-rebuild switch --flake {{flake_path}}#{{host}}

# Build and switch with verbose output
debug host=hostname:
    @echo -e "${BLUE}Debug build for {{host}}...${NC}"
    sudo nixos-rebuild switch --flake {{flake_path}}#{{host}} --show-trace

# Test configuration in a VM
test host=hostname:
    @echo -e "${BLUE}Testing configuration in VM...${NC}"
    nixos-rebuild build-vm --flake {{flake_path}}#{{host}}
    @echo -e "${GREEN}VM built. Run ./result/bin/run-*-vm to start${NC}"

# Update flake inputs
update input="":
    @if [ -z "{{input}}" ]; then \
        echo -e "${BLUE}Updating all flake inputs...${NC}"; \
        nix flake update; \
    else \
        echo -e "${BLUE}Updating flake input: {{input}}...${NC}"; \
        nix flake lock --update-input {{input}}; \
    fi

# Show flake inputs and their versions
inputs:
    @echo -e "${BLUE}=== Flake Inputs ===${NC}"
    @nix flake metadata --json | jq -r '.locks.nodes | to_entries[] | select(.key != "root") | "\(.key): \(.value.locked.rev // .value.locked.narHash)"'

# Search for packages
search query:
    @echo -e "${BLUE}Searching for: {{query}}${NC}"
    @nix search nixpkgs {{query}}

# Garbage collect old generations
clean generations="7d":
    @echo -e "${YELLOW}Cleaning generations older than {{generations}}...${NC}"
    sudo nix-collect-garbage --delete-older-than {{generations}}
    @echo -e "${GREEN}Cleanup complete${NC}"

# Clean build artifacts and temporary files
clean-build:
    @echo -e "${BLUE}Cleaning build artifacts...${NC}"
    @rm -f {{flake_path}}/result*
    @echo -e "${GREEN}Build artifacts cleaned${NC}"

# Full cleanup: generations + build artifacts
clean-all generations="7d": clean-build
    @echo -e "${YELLOW}Full cleanup: generations + build artifacts...${NC}"
    sudo nix-collect-garbage --delete-older-than {{generations}}
    @echo -e "${GREEN}Full cleanup complete${NC}"

# Clean nix store (careful - removes unused packages)
clean-store:
    @echo -e "${RED}WARNING: This will remove all unused packages from nix store${NC}"
    @read -p "Continue? [y/N]: " confirm && [ "$$confirm" = "y" ] || exit 1
    @echo -e "${YELLOW}Cleaning nix store...${NC}"
    sudo nix-collect-garbage -d
    nix-store --gc
    @echo -e "${GREEN}Nix store cleaned${NC}"

# Show system generations
generations:
    @echo -e "${BLUE}=== System Generations ===${NC}"
    @sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
rollback:
    @echo -e "${YELLOW}Rolling back to previous generation...${NC}"
    sudo nixos-rebuild switch --rollback

# Edit system configuration
edit host=hostname:
    $EDITOR {{flake_path}}/hosts/*/{{host}}/configuration.nix

# Edit home-manager configuration
edit-home host=hostname:
    $EDITOR {{flake_path}}/hosts/*/{{host}}/home.nix

# Check configuration for errors
check host=hostname:
    @echo -e "${BLUE}Checking configuration...${NC}"
    nix flake check
    @echo -e "${GREEN}Configuration check passed${NC}"

# Show diff between current and new configuration
diff host=hostname:
    @echo -e "${BLUE}Building and showing diff...${NC}"
    nixos-rebuild build --flake {{flake_path}}#{{host}}
    nvd diff /run/current-system result

# Create a new module
new-module category name:
    @mkdir -p {{flake_path}}/modules/{{category}}
    @echo '{ config, lib, pkgs, ... }:' > {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo 'let' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '  cfg = config.{{category}}.{{name}};' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo 'in' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '{' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '  options.{{category}}.{{name}} = {' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '    enable = lib.mkEnableOption "{{name}}";' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '  };' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '  config = lib.mkIf cfg.enable {' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '    # Configuration goes here' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '  };' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo '}' >> {{flake_path}}/modules/{{category}}/{{name}}.nix
    @echo -e "${GREEN}Created module: modules/{{category}}/{{name}}.nix${NC}"

# Format all nix files
fmt:
    @echo -e "${BLUE}Formatting nix files...${NC}"
    find {{flake_path}} -name "*.nix" -exec nixfmt {} +
    @echo -e "${GREEN}Formatting complete${NC}"

# Note: home-manager is integrated with NixOS, use 'just switch' instead

# Backup current system
backup name=`date +%Y%m%d-%H%M%S`:
    @echo -e "${BLUE}Creating backup: {{name}}${NC}"
    @mkdir -p {{flake_path}}/backups
    @tar -czf {{flake_path}}/backups/{{name}}.tar.gz \
        --exclude='{{flake_path}}/.git' \
        --exclude='{{flake_path}}/backups' \
        {{flake_path}}
    @echo -e "${GREEN}Backup created: backups/{{name}}.tar.gz${NC}"

# Show current module structure
tree:
    @echo -e "${BLUE}=== Module Structure ===${NC}"
    @tree -d -L 3 {{flake_path}}/modules {{flake_path}}/hosts {{flake_path}}/home 2>/dev/null || \
        find {{flake_path}}/modules {{flake_path}}/hosts {{flake_path}}/home -type d | sort

# Run a nix repl with flake
repl:
    @echo -e "${BLUE}Starting Nix REPL with flake...${NC}"
    nix repl --expr "builtins.getFlake \"{{flake_path}}\""

# Update this justfile from the repo
self-update:
    @echo -e "${BLUE}Updating justfile...${NC}"
    @curl -s https://raw.githubusercontent.com/yourusername/nix-config/main/justfile > {{flake_path}}/justfile.new
    @mv {{flake_path}}/justfile.new {{flake_path}}/justfile
    @echo -e "${GREEN}Justfile updated${NC}"

# Manage secrets with agenix
secret action name="":
    @if [ "{{action}}" = "edit" ] && [ -n "{{name}}" ]; then \
        echo -e "${BLUE}Editing secret: {{name}}${NC}"; \
        agenix -e {{flake_path}}/secrets/{{name}}.age; \
    elif [ "{{action}}" = "list" ]; then \
        echo -e "${BLUE}=== Secrets ===${NC}"; \
        ls -la {{flake_path}}/secrets/*.age 2>/dev/null || echo "No secrets found"; \
    else \
        echo -e "${RED}Usage: just secret [edit|list] [name]${NC}"; \
    fi

# Create module structure for refactoring
init-modules:
    @echo -e "${BLUE}Creating module structure...${NC}"
    @mkdir -p {{flake_path}}/modules/{system,desktop,services,users,packages,hardware}
    @mkdir -p {{flake_path}}/home/{profiles,programs}
    @mkdir -p {{flake_path}}/hosts/{desktop,servers}
    @mkdir -p {{flake_path}}/lib
    @echo -e "${GREEN}Module structure created${NC}"

# Quick rebuild alias
rebuild: switch


# Quick update and rebuild
upgrade: update switch

# List available scripts
list-scripts:
    @echo -e "${BLUE}=== Available Scripts ===${NC}"
    @ls -la {{flake_path}}/scripts/*.sh 2>/dev/null | awk '{print $9}' | sed 's/.*\///' | sed 's/\.sh$//' || echo "No scripts found"

# Create a new script template
new-script name:
    @echo -e "${BLUE}Creating new script: {{name}}${NC}"
    @cat > {{flake_path}}/scripts/{{name}}.sh << 'EOF'
    #!/usr/bin/env bash
    
    # {{name}}.sh
    # -----------
    # Description: TODO - Add description
    
    set -euo pipefail
    
    # Script implementation goes here
    echo "TODO: Implement {{name}}"
    EOF
    @chmod +x {{flake_path}}/scripts/{{name}}.sh
    @echo -e "${GREEN}Created script: scripts/{{name}}.sh${NC}"
    @echo "Don't forget to rebuild to install: just switch"

# Edit a script
edit-script name:
    @if [ -f "{{flake_path}}/scripts/{{name}}.sh" ]; then \
        $EDITOR {{flake_path}}/scripts/{{name}}.sh; \
    else \
        echo -e "${RED}Script not found: {{name}}.sh${NC}"; \
        echo "Available scripts:"; \
        just list-scripts; \
    fi

# Test a script locally (without installing)
test-script name *args:
    @if [ -f "{{flake_path}}/scripts/{{name}}.sh" ]; then \
        echo -e "${BLUE}Testing script: {{name}}${NC}"; \
        bash {{flake_path}}/scripts/{{name}}.sh {{args}}; \
    else \
        echo -e "${RED}Script not found: {{name}}.sh${NC}"; \
    fi

# Show script documentation
script-help name:
    @if [ -f "{{flake_path}}/scripts/{{name}}.sh" ]; then \
        echo -e "${BLUE}=== Script: {{name}} ===${NC}"; \
        head -20 {{flake_path}}/scripts/{{name}}.sh | grep -E '^#' | sed 's/^# //'; \
    else \
        echo -e "${RED}Script not found: {{name}}.sh${NC}"; \
    fi

# ──────────────────────────────────────────────────────────────
# Infrastructure Management (OpenTofu + Hetzner + Cloudflare)
# ──────────────────────────────────────────────────────────────

# Check if we're in the nix dev shell (tofu, agenix, jq available)
@_check-infra-deps:
    #!/usr/bin/env bash
    if ! command -v tofu &> /dev/null; then
        echo -e "${RED}ERROR: 'tofu' not found.${NC}" >&2
        echo "Infrastructure commands require nix flake dependencies." >&2
        echo "" >&2
        echo "Run with: nix develop --command just <command>" >&2
        echo "Or enter shell first: nix develop" >&2
        exit 1
    fi

# Get Hetzner API token (with validation)
@_get-token:
    ./scripts/get-hetzner-token.sh

# Get Cloudflare API token
@_get-cf-token:
    cd secrets && agenix -d cloudflare-api-token.age | tr -d '\n\r\t '

# Initialize OpenTofu
tofu-init: _check-infra-deps
    @echo -e "${BLUE}Initializing OpenTofu...${NC}"
    cd terraform && tofu init

# Plan infrastructure changes
tofu-plan: _check-infra-deps
    @echo -e "${BLUE}Planning infrastructure changes...${NC}"
    cd terraform && \
      TF_VAR_hcloud_token="$(just _get-token)" \
      TF_VAR_cloudflare_token="$(just _get-cf-token)" \
      tofu plan

# Apply infrastructure changes
tofu-apply: _check-infra-deps
    @echo -e "${YELLOW}Applying infrastructure changes...${NC}"
    cd terraform && \
      TF_VAR_hcloud_token="$(just _get-token)" \
      TF_VAR_cloudflare_token="$(just _get-cf-token)" \
      tofu apply -auto-approve
    @echo -e "${GREEN}Infrastructure applied successfully${NC}"

# Destroy infrastructure (requires confirmation)
tofu-destroy: _check-infra-deps
    #!/usr/bin/env bash
    set -euo pipefail
    echo -e "${RED}WARNING: This will destroy all infrastructure managed by OpenTofu${NC}"
    read -p "Are you sure you want to destroy? [y/N]: " confirm
    if [ "$confirm" != "y" ]; then
        echo "Cancelled."
        exit 1
    fi
    echo -e "${YELLOW}Destroying infrastructure...${NC}"
    cd terraform && \
      TF_VAR_hcloud_token="$(just _get-token)" \
      TF_VAR_cloudflare_token="$(just _get-cf-token)" \
      tofu destroy -auto-approve
    echo -e "${GREEN}Infrastructure destroyed${NC}"

# Show infrastructure outputs
tofu-output: _check-infra-deps
    @cd terraform && tofu output -json

# Show server IP
tofu-ip: _check-infra-deps
    @cd terraform && tofu output -raw server_ip

# ──────────────────────────────────────────────────────────────
# Server Provisioning (Full workflow with agenix secrets)
# ──────────────────────────────────────────────────────────────

# Step 1: Initialize terraform and generate host key
server-init-key: _check-infra-deps
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{justfile_directory()}}
    echo -e "${BLUE}Initializing terraform and generating host key...${NC}"
    cd terraform && tofu init -upgrade
    TF_VAR_hcloud_token="$(just _get-token)" \
    TF_VAR_cloudflare_token="$(just _get-cf-token)" \
    tofu apply -target=tls_private_key.host_ed25519 -auto-approve
    echo -e "${GREEN}✓ Host key generated${NC}"
    echo ""
    echo -e "${YELLOW}Host public key:${NC}"
    tofu output -raw host_ed25519_public_key
    echo ""

# Step 2: Update secrets.nix with host key and re-key secrets
server-setup-secrets: _check-infra-deps
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{justfile_directory()}}
    echo -e "${BLUE}Setting up agenix secrets for server...${NC}"

    # Get the host key from terraform (strip ANSI codes)
    cd terraform
    HOST_KEY=$(tofu output -raw host_ed25519_public_key 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
    cd ..

    if [ -z "$HOST_KEY" ] || [[ "$HOST_KEY" == *"Warning"* ]]; then
        echo -e "${RED}Error: No host key found. Run 'just server-init-key' first.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Host key: ${HOST_KEY:0:50}...${NC}"

    # Check if key already in secrets.nix
    if grep -q "oddship_web" secrets/secrets.nix; then
        echo -e "${YELLOW}Updating existing oddship_web key in secrets.nix...${NC}"
        # Update the existing key (handles both empty "" and existing ssh-ed25519 keys)
        sed -i "s|oddship_web = \"[^\"]*\";|oddship_web = \"$HOST_KEY\";|" secrets/secrets.nix
    else
        echo -e "${YELLOW}Adding oddship_web key to secrets.nix...${NC}"
        # Add the key after ux303 line
        sed -i "/ux303 = /a\\  oddship_web = \"$HOST_KEY\";" secrets/secrets.nix
        # Add to systems list
        sed -i "s/systems = \[/systems = [\n    oddship_web/" secrets/secrets.nix
        # Add to cloudflare-api-token.age publicKeys
        sed -i '/"cloudflare-api-token.age".publicKeys = \[/,/\];/{
            /thinkpadx1/a\    oddship_web
        }' secrets/secrets.nix
    fi

    echo -e "${BLUE}Re-keying secrets...${NC}"
    cd secrets && agenix -r

    echo -e "${GREEN}✓ Secrets configured for server${NC}"

# Step 3: Full server provision (creates server + installs NixOS)
server-provision: _check-infra-deps
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{justfile_directory()}}/terraform
    echo -e "${BLUE}Provisioning server with NixOS...${NC}"
    TF_VAR_hcloud_token="$(just _get-token)" \
    TF_VAR_cloudflare_token="$(just _get-cf-token)" \
    tofu apply -auto-approve
    echo -e "${GREEN}✓ Server provisioned${NC}"

# Full server setup workflow (init -> secrets -> provision)
server-setup: _check-infra-deps
    #!/usr/bin/env bash
    set -euo pipefail
    cd {{justfile_directory()}}
    echo -e "${BLUE}=== Full Server Setup Workflow ===${NC}"
    echo ""

    echo -e "${YELLOW}Step 1/3: Generating host key...${NC}"
    just server-init-key

    echo ""
    echo -e "${YELLOW}Step 2/3: Setting up agenix secrets...${NC}"
    just server-setup-secrets

    echo ""
    echo -e "${YELLOW}Step 3/3: Provisioning server...${NC}"
    just server-provision

    echo ""
    echo -e "${GREEN}=== Server Setup Complete ===${NC}"
    cd terraform
    SERVER_IP=$(tofu output -raw server_ip)
    echo -e "Server IP: ${SERVER_IP}"
    echo -e "SSH: ssh rhnvrm@${SERVER_IP}"

# ──────────────────────────────────────────────────────────────
# NixOS Deployment (nixos-anywhere + nixos-rebuild)
# ──────────────────────────────────────────────────────────────

# Bootstrap NixOS on a server (gets IP from terraform)
# Usage: just bootstrap oddship-web
bootstrap host:
    #!/usr/bin/env bash
    set -euo pipefail
    echo -e "${BLUE}Bootstrapping NixOS on {{host}}...${NC}"

    # Get server IP from terraform (assumes server name matches host)
    SERVER_IP=$(cd terraform && tofu output -json | jq -r '.server_ip.value')

    if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "null" ]; then
        echo -e "${RED}Error: Could not get server IP from terraform${NC}"
        echo "Make sure terraform has been applied first: just tofu-apply"
        exit 1
    fi

    echo -e "${YELLOW}Target: root@$SERVER_IP${NC}"
    echo -e "${YELLOW}This will WIPE the server and install NixOS${NC}"
    read -p "Continue? [y/N]: " confirm
    [ "$confirm" = "y" ] || exit 0

    nix run github:nix-community/nixos-anywhere -- \
        --flake .#{{host}} \
        --target-host root@$SERVER_IP

    echo -e "${GREEN}✓ NixOS bootstrapped on {{host}}${NC}"
    echo -e "${BLUE}You can now deploy updates with: just deploy {{host}}${NC}"

# Deploy configuration updates to a server (gets IP from terraform)
# Usage: just deploy oddship-web
deploy host:
    #!/usr/bin/env bash
    set -euo pipefail
    echo -e "${BLUE}Deploying {{host}}...${NC}"

    SERVER_IP=$(cd terraform && tofu output -json | jq -r '.server_ip.value')

    if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "null" ]; then
        echo -e "${RED}Error: Could not get server IP from terraform${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Target: rhnvrm@$SERVER_IP${NC}"
    nixos-rebuild switch --flake .#{{host}} \
        --target-host rhnvrm@$SERVER_IP --use-remote-sudo

    echo -e "${GREEN}✓ Deployed {{host}}${NC}"

# Manual bootstrap (for when you have IP but no terraform)
# Usage: just bootstrap-manual oddship-web root@167.235.62.179
bootstrap-manual host target:
    @echo -e "${BLUE}Bootstrapping NixOS on {{host}} at {{target}}...${NC}"
    @echo -e "${YELLOW}This will WIPE the server and install NixOS${NC}"
    @read -p "Continue? [y/N]: " confirm && [ "$$confirm" = "y" ] || exit 0
    nix run github:nix-community/nixos-anywhere -- \
        --flake .#{{host}} \
        --target-host {{target}}
    @echo -e "${GREEN}✓ NixOS bootstrapped${NC}"

# Manual deploy (for when you have IP but no terraform)
# Usage: just deploy-manual oddship-web rhnvrm@167.235.62.179
deploy-manual host target:
    @echo -e "${BLUE}Deploying {{host}} to {{target}}...${NC}"
    nixos-rebuild switch --flake .#{{host}} \
        --target-host {{target}} --use-remote-sudo
    @echo -e "${GREEN}✓ Deployed${NC}"

# Help command
help:
    @echo -e "${BLUE}=== NixOS Management Commands ===${NC}"
    @echo ""
    @echo "Common commands:"
    @echo "  just switch         - Build and switch to new configuration"
    @echo "  just update         - Update flake inputs"
    @echo "  just clean          - Garbage collect old generations"
    @echo "  just clean-build    - Remove build artifacts (result symlinks)"
    @echo "  just clean-all      - Full cleanup (generations + artifacts)"
    @echo "  just search <pkg>   - Search for packages"
    @echo ""
    @echo "Infrastructure commands (OpenTofu):"
    @echo "  just tofu-init      - Initialize OpenTofu"
    @echo "  just tofu-plan      - Plan infrastructure changes"
    @echo "  just tofu-apply     - Apply infrastructure changes"
    @echo "  just tofu-destroy   - Destroy all infrastructure"
    @echo "  just tofu-ip        - Show server IP"
    @echo ""
    @echo "Server Provisioning (recommended workflow):"
    @echo "  just server-setup   - Full setup: init + secrets + provision"
    @echo "  just server-init-key     - Generate host key (step 1)"
    @echo "  just server-setup-secrets - Configure agenix (step 2)"
    @echo "  just server-provision    - Deploy server (step 3)"
    @echo ""
    @echo "NixOS Deployment:"
    @echo "  just bootstrap <host>       - Install NixOS (auto-gets IP from terraform)"
    @echo "  just deploy <host>          - Deploy updates (auto-gets IP from terraform)"
    @echo "  just bootstrap-manual <h> <t> - Install NixOS with manual IP"
    @echo "  just deploy-manual <h> <t>    - Deploy updates with manual IP"
    @echo ""
    @echo "Script management:"
    @echo "  just list-scripts   - List available scripts"
    @echo "  just new-script <n> - Create new script template"
    @echo "  just edit-script <n>- Edit existing script"
    @echo "  just test-script <n>- Test script without installing"
    @echo ""
    @echo "Advanced commands:"
    @echo "  just test           - Test configuration in VM"
    @echo "  just diff           - Show diff with current system"
    @echo "  just secret edit <n>- Edit encrypted secret"
    @echo ""
    @echo "Run 'just --list' for all commands"