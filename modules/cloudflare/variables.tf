variable "account_id" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "extra_hostnames" {
  description = "Additional hostnames to route through the tunnel (key = subdomain, value = port)"
  type    = map(number)
  default = {}
}

variable "access_allowed_emails" {
  description = "Emails allowed to access protected applications via Cloudflare Access"
  type    = list(string)
  default = []
}
