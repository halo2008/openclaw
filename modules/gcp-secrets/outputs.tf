output "eso_sa_key_json" {
  description = "ESO service account key (JSON) for k8s secret"
  value       = base64decode(google_service_account_key.eso.private_key)
  sensitive   = true
}

output "eso_sa_email" {
  description = "ESO service account email"
  value       = google_service_account.eso.email
}

output "kms_crypto_key_id" {
  description = "KMS crypto key ID for encryption"
  value       = google_kms_crypto_key.openclaw.id
}
