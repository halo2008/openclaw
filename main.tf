resource "random_password" "gateway_token" {
  length  = 32
  special = false
}

locals {
  project       = "openclaw"
  gateway_token = var.gateway_token != "" ? var.gateway_token : random_password.gateway_token.result
  base_domain   = join(".", slice(split(".", var.domain), 1, length(split(".", var.domain))))
  n8n_host      = "n8n.${local.base_domain}"
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

# --- Infrastructure modules (Hetzner + Cloudflare) ---

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

  account_id            = var.cloudflare_account_id
  zone_id               = var.cloudflare_zone_id
  domain                = var.domain
  extra_hostnames       = var.extra_hostnames
  access_allowed_emails = var.access_allowed_emails
  project               = local.project
  environment           = var.environment
}

module "server" {
  source = "./modules/server"

  project              = local.project
  environment          = var.environment
  location             = var.location
  server_type          = var.server_type
  ssh_key_id           = hcloud_ssh_key.default.id
  network_id           = module.network.network_id
  subnet_id            = module.network.subnet_id
  firewall_ids         = [module.firewall.firewall_id]
  labels               = local.labels
  tunnel_token         = module.cloudflare.tunnel_token
  ssh_port             = var.ssh_port
  ssh_user             = var.ssh_user
  ssh_pub_key          = file(var.ssh_public_key_path)
  ssh_private_key_path = var.ssh_private_key_path
  openclaw_version     = var.openclaw_version
}

# --- GCP Secret Manager + KMS ---

module "gcp_secrets" {
  source = "./modules/gcp-secrets"

  gcp_project_id     = var.gcp_project_id
  gcp_region         = var.gcp_region
  deepseek_api_key   = var.deepseek_api_key
  google_api_key     = var.google_api_key
  google_api_key_2   = var.google_api_key_2
  groq_api_key       = var.groq_api_key
  sambanova_api_key  = var.sambanova_api_key
  cerebras_api_key   = var.cerebras_api_key
  gateway_token      = local.gateway_token
  n8n_encryption_key = var.n8n_encryption_key
  firebase_sa_json   = var.firebase_sa_json
}

# --- Kubernetes base (namespace, PVCs, ConfigMaps) ---

module "k8s_base" {
  source = "./modules/k8s-base"

  domain        = var.domain
  default_model = var.default_model
  enable_cron   = var.enable_cron
  cron_jobs     = var.cron_jobs

  depends_on = [module.server]
}

# --- External Secrets Operator ---

module "k8s_operators" {
  source = "./modules/k8s-operators"

  gcp_project_id = var.gcp_project_id
  eso_sa_key_json = module.gcp_secrets.eso_sa_key_json

  depends_on = [module.k8s_base]
}

# --- Application deployments ---

module "k8s_apps" {
  source = "./modules/k8s-apps"

  namespace        = "openclaw"
  openclaw_version = var.openclaw_version
  n8n_version      = var.n8n_version
  n8n_host         = local.n8n_host
  domain           = var.domain
  enable_fcm       = var.enable_fcm
  enable_cron      = var.enable_cron
  cron_jobs_count  = length(var.cron_jobs)

  depends_on = [module.k8s_operators]
}

# --- Network policies ---

module "k8s_network" {
  source = "./modules/k8s-network"

  namespace  = "openclaw"
  enable_fcm = var.enable_fcm

  depends_on = [module.k8s_base]
}

# --- Monitoring (Prometheus agent + Alloy → Grafana Cloud) ---

module "k8s_monitoring" {
  source = "./modules/k8s-monitoring"

  grafana_cloud_prometheus_url = var.grafana_cloud_prometheus_url
  grafana_cloud_loki_url       = var.grafana_cloud_loki_url
  grafana_cloud_user           = var.grafana_cloud_user
  grafana_cloud_api_key        = var.grafana_cloud_api_key

  depends_on = [module.server]
}
