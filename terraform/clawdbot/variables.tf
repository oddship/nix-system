variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for installation"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "debug_logging" {
  description = "Enable debug logging for nixos-anywhere"
  type        = bool
  default     = true
}
