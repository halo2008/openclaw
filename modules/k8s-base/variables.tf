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

variable "cron_jobs" {
  type = list(object({
    id            = string
    name          = string
    schedule_expr = string
    schedule_tz   = optional(string, "Europe/Warsaw")
    message       = string
  }))
  default = []
}
