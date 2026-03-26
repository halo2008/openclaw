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
  description = "Cloudflare zone ID for ks-infra.dev"
  type        = string
}

variable "domain" {
  description = "Domain for the main service"
  type        = string
  default     = "claw.ks-infra.dev"
}

variable "extra_hostnames" {
  description = "Additional services exposed via Cloudflare Tunnel (key = subdomain)"
  type        = map(number)
  default = {
    n8n    = 5678
    qdrant = 6333
  }
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
