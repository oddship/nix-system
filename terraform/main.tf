terraform {
  required_providers {
    hcloud = {
      source  = "opentofu/hcloud"
      version = "~> 1.52.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

# SSH Key
resource "hcloud_ssh_key" "default" {
  name       = "oddship-deploy"
  public_key = file(var.ssh_public_key_path)
}

# Server
resource "hcloud_server" "web" {
  name        = "oddship-web"
  server_type = "cpx11"       # 2 vCPU, 2GB RAM, ~$4/mo
  image       = "debian-12"   # Will be replaced by nixos-anywhere
  location    = "nbg1"        # Nuremberg, Germany
  backups     = true

  ssh_keys = [hcloud_ssh_key.default.id]
}

# Firewall
resource "hcloud_firewall" "web" {
  name = "web-firewall"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall_attachment" "web" {
  firewall_id = hcloud_firewall.web.id
  server_ids  = [hcloud_server.web.id]
}

# nixos-anywhere - Install NixOS on the server
module "nixos_anywhere" {
  source = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"

  # The flake attributes for the NixOS system
  nixos_system_attr      = "..#nixosConfigurations.oddship-web.config.system.build.toplevel"
  nixos_partitioner_attr = "..#nixosConfigurations.oddship-web.config.system.build.diskoScript"

  # Target host details
  target_host = hcloud_server.web.ipv4_address
  target_user = "root"
  target_port = 22

  # Use instance_id to track when to reinstall
  instance_id = hcloud_server.web.id

  # SSH key for installation (read from file)
  install_ssh_key = file(var.ssh_private_key_path)

  # Enable debug logging to see what's happening
  debug_logging = var.debug_logging

  # Build on remote to avoid large uploads
  build_on_remote = true
}

# Cloudflare - oddship.net
data "cloudflare_zone" "oddship" {
  name = "oddship.net"
}

resource "cloudflare_record" "oddship_root" {
  zone_id = data.cloudflare_zone.oddship.id
  name    = "@"
  content = hcloud_server.web.ipv4_address
  type    = "A"
  proxied = true  # Orange cloud for IP hiding + DDoS protection
}

resource "cloudflare_record" "oddship_www" {
  zone_id = data.cloudflare_zone.oddship.id
  name    = "www"
  content = "oddship.net"
  type    = "CNAME"
  proxied = true
}

