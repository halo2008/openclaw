terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

# --- Enable APIs ---

resource "google_project_service" "secretmanager" {
  project            = var.gcp_project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "kms" {
  project            = var.gcp_project_id
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project            = var.gcp_project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# --- KMS ---

resource "google_kms_key_ring" "openclaw" {
  name     = "openclaw"
  location = var.gcp_region
  project  = var.gcp_project_id

  depends_on = [google_project_service.kms]
}

resource "google_kms_crypto_key" "openclaw" {
  name            = "openclaw-secrets"
  key_ring        = google_kms_key_ring.openclaw.id
  rotation_period = "2592000s" # 30 days

  lifecycle {
    prevent_destroy = true
  }
}

# --- Service Account for External Secrets Operator ---

resource "google_service_account" "eso" {
  project      = var.gcp_project_id
  account_id   = "openclaw-eso"
  display_name = "OpenClaw External Secrets Operator"

  depends_on = [google_project_service.iam]
}

resource "google_project_iam_member" "eso_secret_accessor" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso.email}"
}

resource "google_service_account_key" "eso" {
  service_account_id = google_service_account.eso.name
}

# --- Secret Manager secrets ---

locals {
  secrets = {
    "openclaw-deepseek-api-key"  = var.deepseek_api_key
    "openclaw-google-api-key"    = var.google_api_key
    "openclaw-google-api-key-2"  = var.google_api_key_2
    "openclaw-groq-api-key"      = var.groq_api_key
    "openclaw-sambanova-api-key" = var.sambanova_api_key
    "openclaw-cerebras-api-key"  = var.cerebras_api_key
    "openclaw-gateway-token"     = var.gateway_token
    "openclaw-n8n-encryption-key" = var.n8n_encryption_key
    "openclaw-firebase-sa"       = var.firebase_sa_json
  }
}

resource "google_secret_manager_secret" "secrets" {
  for_each  = local.secrets
  project   = var.gcp_project_id
  secret_id = each.key

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "secrets" {
  for_each    = local.secrets
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value != "" ? each.value : "PLACEHOLDER"

  lifecycle {
    ignore_changes = [secret_data]
  }
}
