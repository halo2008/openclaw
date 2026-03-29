output "ipv4_address" {
  value = hcloud_server.main.ipv4_address
}

output "ipv6_address" {
  value = hcloud_server.main.ipv6_address
}

output "private_ip" {
  value = one(hcloud_server.main.network[*].ip)
}

output "server_name" {
  value = hcloud_server.main.name
}

output "server_id" {
  value = hcloud_server.main.id
}

output "kubeconfig_ready" {
  description = "Signals that kubeconfig has been fetched"
  value       = null_resource.fetch_kubeconfig.id
}
