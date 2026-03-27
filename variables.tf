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

variable "domain" {
  description = "Domain for the main service"
  type        = string
  default     = "claw.example.com"
}

variable "extra_hostnames" {
  description = "Additional services exposed via Cloudflare Tunnel (key = subdomain)"
  type        = map(number)
  default = {
    n8n    = 5678
    qdrant = 6333
  }
}

variable "access_allowed_emails" {
  description = "Emails allowed to access OpenClaw via Cloudflare Access"
  type        = list(string)
  default     = ["your-email@example.com"]
}

variable "enable_kokoro" {
  description = "Enable Kokoro TTS service (English)"
  type        = bool
  default     = true
}

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

variable "openclaw_version" {
  description = "Git ref (tag/branch/commit) for OpenClaw build"
  type        = string
  default     = "main"
}

variable "qdrant_version" {
  description = "Qdrant Docker image tag"
  type        = string
  default     = "v1.13.6"
}

variable "n8n_version" {
  description = "n8n Docker image tag"
  type        = string
  default     = "1.88.0"
}

variable "kokoro_version" {
  description = "Kokoro FastAPI Docker image tag"
  type        = string
  default     = "v0.4.3"
}

variable "piper_version" {
  description = "Piper Docker image tag"
  type        = string
  default     = "latest"
}

variable "deepseek_api_key" {
  description = "DeepSeek API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "google_api_key" {
  description = "Google Gemini API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "default_model" {
  description = "Default LLM model for the agent"
  type        = string
  default     = "google/gemini-3.1-flash-lite-preview"
}

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
