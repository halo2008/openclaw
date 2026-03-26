output "server_ipv4" {
  description = "Public IPv4 address (SSH only)"
  value       = module.server.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address"
  value       = module.server.ipv6_address
}

output "server_private_ip" {
  description = "Private IP in VPC"
  value       = module.server.private_ip
}

output "server_name" {
  value = module.server.server_name
}

output "app_url" {
  description = "Application URL via Cloudflare Tunnel"
  value       = "https://${var.domain}"
}

output "tunnel_id" {
  description = "Cloudflare Tunnel ID"
  value       = module.cloudflare.tunnel_id
}
