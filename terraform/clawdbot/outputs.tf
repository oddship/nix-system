output "server_ip" {
  value = hcloud_server.clawdbot.ipv4_address
}

output "server_id" {
  value = hcloud_server.clawdbot.id
}

output "host_ed25519_public_key" {
  value = tls_private_key.host_ed25519.public_key_openssh
}
