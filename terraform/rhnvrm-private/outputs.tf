output "server_ipv6" {
  value = hcloud_server.rhnvrm.ipv6_address
}

output "server_id" {
  value = hcloud_server.rhnvrm.id
}

output "host_ed25519_public_key" {
  value = tls_private_key.host_ed25519.public_key_openssh
}

output "server_ipv4" {
  value = hcloud_server.rhnvrm.ipv4_address
}
