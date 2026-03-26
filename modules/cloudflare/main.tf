terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

locals {
  domain_parts = split(".", var.domain)
  base_domain  = join(".", slice(local.domain_parts, 1, length(local.domain_parts)))
}

resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_tunnel" "main" {
  account_id = var.account_id
  name       = "${var.project}-${var.environment}"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "main" {
  account_id = var.account_id
  tunnel_id  = cloudflare_tunnel.main.id

  config {
    ingress_rule {
      hostname = var.domain
      service  = "http://localhost:8080"
    }

    dynamic "ingress_rule" {
      for_each = var.extra_hostnames
      content {
        hostname = "${ingress_rule.key}.${local.base_domain}"
        service  = "http://localhost:${ingress_rule.value}"
      }
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "tunnel" {
  zone_id = var.zone_id
  name    = local.domain_parts[0]
  content = "${cloudflare_tunnel.main.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "extra" {
  for_each = var.extra_hostnames

  zone_id = var.zone_id
  name    = each.key
  content = "${cloudflare_tunnel.main.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
