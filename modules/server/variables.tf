variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "server_type" {
  type = string
}

variable "ssh_key_id" {
  type = number
}

variable "network_id" {
  type = number
}

variable "subnet_id" {
  type = string
}

variable "firewall_ids" {
  type = list(number)
}

variable "labels" {
  type = map(string)
}

variable "tunnel_token" {
  description = "Cloudflare Tunnel token for cloudflared"
  type        = string
  sensitive   = true
}

variable "ssh_port" {
  description = "Custom SSH port"
  type        = number
}

variable "ssh_user" {
  description = "Non-root SSH user"
  type        = string
}

variable "ssh_pub_key" {
  description = "SSH public key content"
  type        = string
}

variable "n8n_host" {
  description = "n8n public hostname"
  type        = string
}

variable "enable_kokoro" {
  description = "Enable Kokoro TTS service (English)"
  type        = bool
  default     = true
}

variable "enable_piper" {
  description = "Enable Piper TTS service (Polish)"
  type        = bool
  default     = true
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

variable "default_model" {
  description = "Default LLM model for the agent"
  type        = string
  default     = "deepseek/deepseek-chat"
}

variable "google_api_key" {
  description = "Google Gemini API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "domain" {
  description = "Main domain for the service"
  type        = string
}

variable "enable_fcm" {
  description = "Enable FCM push notification service"
  type        = bool
  default     = false
}

variable "gateway_token" {
  description = "OpenClaw gateway auth token"
  type        = string
  sensitive   = true
}

variable "enable_cron" {
  description = "Enable OpenClaw cron scheduler for automated tasks"
  type        = bool
  default     = true
}

variable "cron_jobs" {
  description = "List of cron jobs to pre-configure (injected into cron/jobs.json)"
  type = list(object({
    id             = string
    name           = string
    schedule_expr  = string
    schedule_tz    = optional(string, "Europe/Warsaw")
    message        = string
  }))
  default = []
}

