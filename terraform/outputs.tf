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
