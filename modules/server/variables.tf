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

variable "openclaw_version" {
  description = "Git ref (tag/branch/commit) for OpenClaw build"
  type        = string
  default     = "main"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key (for provisioners)"
  type        = string
}
