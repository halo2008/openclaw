terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "openclaw" {
  metadata {
    name = "openclaw"
    labels = {
      project = "openclaw"
    }
  }
}

# --- PVCs (k3s local-path-provisioner) ---

resource "kubernetes_persistent_volume_claim" "openclaw_data" {
  metadata {
    name      = "openclaw-data"
    namespace = kubernetes_namespace.openclaw.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-path"
    resources {
      requests = { storage = "5Gi" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "n8n_data" {
  metadata {
    name      = "n8n-data"
    namespace = kubernetes_namespace.openclaw.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-path"
    resources {
      requests = { storage = "5Gi" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "fcm_data" {
  metadata {
    name      = "fcm-data"
    namespace = kubernetes_namespace.openclaw.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-path"
    resources {
      requests = { storage = "1Gi" }
    }
  }
}

# --- ConfigMaps ---

resource "kubernetes_config_map" "openclaw_config" {
  metadata {
    name      = "openclaw-config"
    namespace = kubernetes_namespace.openclaw.metadata[0].name
  }
  data = {
    "openclaw.json" = templatefile("${path.module}/../../modules/server/templates/openclaw.json.tpl", {
      default_model = var.default_model
      domain        = var.domain
      enable_cron   = var.enable_cron
    })
  }
}

resource "kubernetes_config_map" "cron_jobs" {
  count = length(var.cron_jobs) > 0 ? 1 : 0

  metadata {
    name      = "cron-jobs"
    namespace = kubernetes_namespace.openclaw.metadata[0].name
  }
  data = {
    "jobs.json" = templatefile("${path.module}/../../modules/server/templates/cron-jobs.json.tpl", {
      cron_jobs = var.cron_jobs
    })
  }
}
