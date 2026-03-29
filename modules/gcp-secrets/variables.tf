variable "gcp_project_id" {
  description = "GCP project ID for Secret Manager and KMS"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for KMS key ring"
  type        = string
  default     = "europe-west3"
}

# --- Secret seed values (initial population from tfvars) ---

variable "deepseek_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "google_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "google_api_key_2" {
  type      = string
  sensitive = true
  default   = ""
}

variable "groq_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "sambanova_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cerebras_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "gateway_token" {
  type      = string
  sensitive = true
}

variable "n8n_encryption_key" {
  type      = string
  sensitive = true
}

variable "firebase_sa_json" {
  description = "Firebase service account JSON (raw, not base64)"
  type        = string
  sensitive   = true
  default     = ""
}
