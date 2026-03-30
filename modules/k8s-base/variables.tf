variable "domain" {
  type = string
}

variable "default_model" {
  type = string
}

variable "enable_cron" {
  type    = bool
  default = true
}

variable "user_profile" {
  description = "USER.md content - agent's knowledge about the user"
  type        = string
  default     = ""
}

variable "cron_jobs" {
  type = list(object({
    id            = string
    name          = string
    schedule_expr = string
    schedule_tz   = optional(string, "Europe/Warsaw")
    message       = string
    webhook_url   = string
  }))
  default = []
}
