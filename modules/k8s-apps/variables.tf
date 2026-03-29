variable "namespace" {
  type    = string
  default = "openclaw"
}

variable "openclaw_version" {
  type    = string
  default = "latest"
}

variable "n8n_version" {
  type    = string
  default = "latest"
}

variable "n8n_host" {
  description = "n8n public hostname"
  type        = string
}

variable "domain" {
  type = string
}

variable "enable_fcm" {
  type    = bool
  default = false
}

variable "enable_cron" {
  type    = bool
  default = true
}

variable "cron_jobs_count" {
  description = "Number of cron jobs (to decide if cron configmap exists)"
  type        = number
  default     = 0
}
