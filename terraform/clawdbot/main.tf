terraform {
  required_providers {
    hcloud = {
      source  = "opentofu/hcloud"
      version = "~> 1.52.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Generate SSH host key for agenix
resource "tls_private_key" "host_ed25519" {
  algorithm = "ED25519"
}

provider "hcloud" {
  token = var.hcloud_token
}

# SSH Key - use existing key from main terraform
data "hcloud_ssh_key" "default" {
  name = "oddship-deploy"
}

# Server
resource "hcloud_server" "clawdbot" {
  name        = "oddship-clawdbot"
  server_type = "ccx13"       # 2 vCPU dedicated, 8GB RAM
  image       = "debian-12"   # Replaced by nixos-anywhere
  location    = "fsn1"        # Falkenstein, Germany
  backups     = true
  ssh_keys    = [data.hcloud_ssh_key.default.id]
}

# Firewall - SSH only
resource "hcloud_firewall" "clawdbot" {
  name = "clawdbot-firewall"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall_attachment" "clawdbot" {
  firewall_id = hcloud_firewall.clawdbot.id
  server_ids  = [hcloud_server.clawdbot.id]
}

# Script to inject SSH host key
resource "local_file" "extra_files_script" {
  filename        = "${path.module}/extra-files.sh"
  file_permission = "0755"
  content         = <<-EOF
    #!/usr/bin/env bash
    mkdir -p etc/ssh
    echo '${tls_private_key.host_ed25519.private_key_openssh}' > etc/ssh/ssh_host_ed25519_key
    echo '${tls_private_key.host_ed25519.public_key_openssh}' > etc/ssh/ssh_host_ed25519_key.pub
    chmod 600 etc/ssh/ssh_host_ed25519_key
    chmod 644 etc/ssh/ssh_host_ed25519_key.pub
  EOF
}

# nixos-anywhere
module "nixos_anywhere" {
  source = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"

  nixos_system_attr      = "../..#nixosConfigurations.oddship-clawdbot.config.system.build.toplevel"
  nixos_partitioner_attr = "../..#nixosConfigurations.oddship-clawdbot.config.system.build.diskoScript"
  target_host            = hcloud_server.clawdbot.ipv4_address
  target_user            = "root"
  target_port            = 22
  instance_id            = hcloud_server.clawdbot.id
  install_ssh_key        = file(var.ssh_private_key_path)
  debug_logging          = var.debug_logging
  build_on_remote        = true
  extra_files_script     = local_file.extra_files_script.filename
}
