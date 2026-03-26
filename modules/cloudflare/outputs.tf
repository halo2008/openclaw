output "tunnel_id" {
  value = cloudflare_tunnel.main.id
}

output "tunnel_token" {
  value     = cloudflare_tunnel.main.tunnel_token
  sensitive = true
}

output "tunnel_cname" {
  value = "${cloudflare_tunnel.main.id}.cfargotunnel.com"
}
