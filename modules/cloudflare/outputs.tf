output "tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.main.id
}

output "tunnel_token" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.main.tunnel_token
  sensitive = true
}

output "tunnel_cname" {
  value = "${cloudflare_zero_trust_tunnel_cloudflared.main.id}.cfargotunnel.com"
}
