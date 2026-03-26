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

resource "cloudflare_zero_trust_tunnel_cloudflared" "main" {
  account_id = var.account_id
  name       = "${var.project}-${var.environment}"
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "main" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.main.id

  config {
    ingress_rule {
      hostname = var.domain
      service  = "http://localhost:18789"
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
  content = "${cloudflare_zero_trust_tunnel_cloudflared.main.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_zero_trust_access_application" "claw" {
  account_id          = var.account_id
  name                = "${var.project}-control-ui"
  domain              = var.domain
  type                = "self_hosted"
  session_duration    = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_zero_trust_access_policy" "claw" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.claw.id
  name           = "Allow owner emails"
  decision       = "allow"
  precedence     = 1

  include {
    email = var.access_allowed_emails
  }
}

resource "cloudflare_record" "extra" {
  for_each = var.extra_hostnames

  zone_id = var.zone_id
  name    = each.key
  content = "${cloudflare_zero_trust_tunnel_cloudflared.main.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
