locals {
  project     = "openclaw"
  labels = {
    project     = local.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "hcloud_ssh_key" "default" {
  name       = "${local.project}-${var.environment}"
  public_key = file(var.ssh_public_key_path)
}

module "network" {
  source = "./modules/network"

  project         = local.project
  environment     = var.environment
  vpc_ip_range    = var.vpc_ip_range
  subnet_ip_range = var.subnet_ip_range
  labels          = local.labels
}

module "firewall" {
  source = "./modules/firewall"

  project         = local.project
  environment     = var.environment
  allowed_ssh_ips = var.allowed_ssh_ips
  ssh_port        = var.ssh_port
  labels          = local.labels
}

module "cloudflare" {
  source = "./modules/cloudflare"

  account_id    = var.cloudflare_account_id
  zone_id       = var.cloudflare_zone_id
  domain        = var.domain
  extra_hostnames = merge(
    var.extra_hostnames,
    var.enable_kokoro ? { kokoro = 8880 } : {},
    var.enable_piper ? { piper = 10200 } : {},
  )
  access_allowed_emails = var.access_allowed_emails
  project               = local.project
  environment           = var.environment
}

module "server" {
  source = "./modules/server"

  project      = local.project
  environment  = var.environment
  location     = var.location
  server_type  = var.server_type
  ssh_key_id   = hcloud_ssh_key.default.id
  network_id   = module.network.network_id
  subnet_id    = module.network.subnet_id
  firewall_ids = [module.firewall.firewall_id]
  labels       = local.labels
  tunnel_token   = module.cloudflare.tunnel_token
  ssh_port       = var.ssh_port
  ssh_user       = var.ssh_user
  ssh_pub_key    = file(var.ssh_public_key_path)
  n8n_host       = "n8n.${join(".", slice(split(".", var.domain), 1, length(split(".", var.domain))))}"
  enable_kokoro     = var.enable_kokoro
  openclaw_version  = var.openclaw_version
  qdrant_version    = var.qdrant_version
  n8n_version       = var.n8n_version
  kokoro_version    = var.kokoro_version
  piper_version     = var.piper_version
  deepseek_api_key  = var.deepseek_api_key
  google_api_key    = var.google_api_key
  default_model     = var.default_model
  domain            = var.domain
}
