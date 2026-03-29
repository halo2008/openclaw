variable "gcp_project_id" {
  type = string
}

variable "eso_sa_key_json" {
  description = "GCP service account key JSON for ESO"
  type        = string
  sensitive   = true
}
