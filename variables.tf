# --- Infrastructure ---

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token (DNS + Tunnel permissions)"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for your domain"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID for Secret Manager and KMS"
  type        = string
  default     = "pacific-attic-191816"
}

variable "gcp_region" {
  description = "GCP region for KMS and resources"
  type        = string
  default     = "europe-west3"
}

# --- Domain & access ---

variable "domain" {
  description = "Domain for the main service"
  type        = string
  default     = "claw.example.com"
}

variable "extra_hostnames" {
  description = "Additional services exposed via Cloudflare Tunnel (key = subdomain, value = NodePort)"
  type        = map(number)
  default = {
    n8n = 30678
  }
}

variable "access_allowed_emails" {
  description = "Emails allowed to access OpenClaw via Cloudflare Access"
  type        = list(string)
  default     = ["your-email@example.com"]
}

# --- Server ---

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx33"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key (for provisioners)"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_port" {
  description = "Custom SSH port"
  type        = number
  default     = 2222
}

variable "ssh_user" {
  description = "Non-root SSH user name"
  type        = string
  default     = "deploy"
}

variable "allowed_ssh_ips" {
  description = "IPs allowed for SSH access (CIDR)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

# --- Networking ---

variable "vpc_ip_range" {
  description = "IP range for VPC network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_ip_range" {
  description = "IP range for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# --- Application ---

variable "openclaw_version" {
  description = "Git ref (tag/branch/commit) for OpenClaw build"
  type        = string
  default     = "main"
}

variable "default_model" {
  description = "Default LLM model for the agent"
  type        = string
  default     = "google/gemini-3.1-flash-lite-preview"
}

variable "enable_cron" {
  description = "Enable OpenClaw cron scheduler for automated tasks"
  type        = bool
  default     = true
}

variable "cron_jobs" {
  description = "Pre-configured cron jobs (injected on first deploy)"
  type = list(object({
    id            = string
    name          = string
    schedule_expr = string
    schedule_tz   = optional(string, "Europe/Warsaw")
    message       = string
  }))
  default = []
}

variable "enable_fcm" {
  description = "Enable FCM push notification service"
  type        = bool
  default     = false
}

variable "n8n_version" {
  description = "n8n Docker image tag"
  type        = string
  default     = "latest"
}

# --- Secret seeds (initial population of GCP Secret Manager) ---

variable "deepseek_api_key" {
  description = "DeepSeek API key (seed for GCP SM)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "google_api_key" {
  description = "Google Gemini API key (seed for GCP SM)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "google_api_key_2" {
  description = "Google Gemini API key backup (seed for GCP SM)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "groq_api_key" {
  description = "Groq API key (seed for GCP SM)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "sambanova_api_key" {
  description = "SambaNova API key (seed for GCP SM)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cerebras_api_key" {
  description = "Cerebras API key (seed for GCP SM)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "gateway_token" {
  description = "OpenClaw gateway auth token (auto-generated if empty)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "n8n_encryption_key" {
  description = "n8n encryption key for credentials DB"
  type        = string
  sensitive   = true
}

variable "firebase_sa_json" {
  description = "Firebase service account JSON (raw)"
  type        = string
  sensitive   = true
  default     = ""
}

# --- Monitoring (Grafana Cloud) ---

variable "grafana_cloud_prometheus_url" {
  description = "Grafana Cloud Prometheus remote write URL"
  type        = string
  default     = ""
}

variable "grafana_cloud_loki_url" {
  description = "Grafana Cloud Loki push URL"
  type        = string
  default     = ""
}

variable "grafana_cloud_user" {
  description = "Grafana Cloud user/instance ID"
  type        = string
  default     = ""
}

variable "grafana_cloud_api_key" {
  description = "Grafana Cloud API key for remote write"
  type        = string
  sensitive   = true
  default     = ""
}
