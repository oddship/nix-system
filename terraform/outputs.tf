output "server_ip" {
  value       = hcloud_server.web.ipv4_address
  description = "Server IPv4 address"
}

output "server_id" {
  value       = hcloud_server.web.id
  description = "Server ID"
}

output "server_name" {
  value       = hcloud_server.web.name
  description = "Server name"
}

output "nixos_anywhere_result" {
  value       = module.nixos_anywhere.result
  description = "nixos-anywhere deployment result"
}
