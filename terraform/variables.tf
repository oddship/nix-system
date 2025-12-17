variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "cloudflare_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token"
}

variable "server_type" {
  default = "cpx11"
}

variable "location" {
  default = "nbg1"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  default     = "~/.ssh/id_ed25519"
  description = "Path to SSH private key for nixos-anywhere installation"
}

variable "debug_logging" {
  type        = bool
  default     = true
  description = "Enable debug logging for nixos-anywhere"
}
