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

