terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

# --- ExternalSecrets ---

resource "kubectl_manifest" "openclaw_api_keys" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: openclaw-api-keys
  namespace: ${var.namespace}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: gcp-secret-store
    kind: ClusterSecretStore
  target:
    name: openclaw-api-keys
  data:
  - secretKey: DEEPSEEK_API_KEY
    remoteRef:
      key: openclaw-deepseek-api-key
  - secretKey: GOOGLE_API_KEY
    remoteRef:
      key: openclaw-google-api-key
  - secretKey: GOOGLE_API_KEY_2
    remoteRef:
      key: openclaw-google-api-key-2
  - secretKey: GROQ_API_KEY
    remoteRef:
      key: openclaw-groq-api-key
  - secretKey: SAMBANOVA_API_KEY
    remoteRef:
      key: openclaw-sambanova-api-key
  - secretKey: CEREBRAS_API_KEY
    remoteRef:
      key: openclaw-cerebras-api-key
  - secretKey: GATEWAY_TOKEN
    remoteRef:
      key: openclaw-gateway-token
  - secretKey: N8N_ENCRYPTION_KEY
    remoteRef:
      key: openclaw-n8n-encryption-key
YAML
}

resource "kubectl_manifest" "firebase_sa" {
  count = var.enable_fcm ? 1 : 0

  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: firebase-sa
  namespace: ${var.namespace}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: gcp-secret-store
    kind: ClusterSecretStore
  target:
    name: firebase-sa
  data:
  - secretKey: firebase-sa.json
    remoteRef:
      key: openclaw-firebase-sa
YAML
}

# --- OpenClaw Deployment ---

resource "kubernetes_deployment" "openclaw" {
  metadata {
    name      = "openclaw"
    namespace = var.namespace
    labels    = { app = "openclaw" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "openclaw" }
    }

    template {
      metadata {
        labels = { app = "openclaw" }
      }

      spec {
        security_context {
          run_as_user = 1000
          fs_group    = 1000
        }

        init_container {
          name  = "config-renderer"
          image = "busybox:1.37"

          command = ["/bin/sh", "-c"]
          args = [<<-EOT
            cp /config-template/openclaw.json /rendered-config/openclaw.json
            sed -i "s|__DEEPSEEK_API_KEY__|$DEEPSEEK_API_KEY|g" /rendered-config/openclaw.json
            sed -i "s|__GOOGLE_API_KEY__|$GOOGLE_API_KEY|g" /rendered-config/openclaw.json
            sed -i "s|__GOOGLE_API_KEY_2__|$GOOGLE_API_KEY_2|g" /rendered-config/openclaw.json
            sed -i "s|__GROQ_API_KEY__|$GROQ_API_KEY|g" /rendered-config/openclaw.json
            sed -i "s|__SAMBANOVA_API_KEY__|$SAMBANOVA_API_KEY|g" /rendered-config/openclaw.json
            sed -i "s|__CEREBRAS_API_KEY__|$CEREBRAS_API_KEY|g" /rendered-config/openclaw.json
            if [ -f /config-template/jobs.json ]; then
              mkdir -p /rendered-config/cron
              cp /config-template/jobs.json /rendered-config/cron/jobs.json
              mkdir -p /data/cron
              cp /config-template/jobs.json /data/cron/jobs.json
            fi
            mkdir -p /data/workspace
            if [ -f /workspace-template/USER.md ]; then
              cp /workspace-template/USER.md /data/workspace/USER.md
            fi
          EOT
          ]

          env_from {
            secret_ref {
              name = "openclaw-api-keys"
            }
          }

          volume_mount {
            name       = "config-template"
            mount_path = "/config-template"
          }

          volume_mount {
            name       = "rendered-config"
            mount_path = "/rendered-config"
          }

          volume_mount {
            name       = "openclaw-data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "workspace-template"
            mount_path = "/workspace-template"
          }
        }

        container {
          name  = "openclaw"
          image = "localhost/openclaw:latest"
          image_pull_policy = "Never"

          port {
            container_port = 18789
          }

          command = ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789", "--allow-unconfigured"]

          env {
            name  = "HOME"
            value = "/home/node"
          }

          env {
            name  = "OPENCLAW_GATEWAY_BIND"
            value = "lan"
          }

          env {
            name = "OPENCLAW_GATEWAY_TOKEN"
            value_from {
              secret_key_ref {
                name = "openclaw-api-keys"
                key  = "GATEWAY_TOKEN"
              }
            }
          }

          volume_mount {
            name       = "openclaw-data"
            mount_path = "/home/node/.openclaw"
          }

          volume_mount {
            name       = "rendered-config"
            mount_path = "/home/node/.openclaw/openclaw.json"
            sub_path   = "openclaw.json"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "2000m"
              memory = "4Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 18789
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }

        volume {
          name = "openclaw-data"
          persistent_volume_claim {
            claim_name = "openclaw-data"
          }
        }

        volume {
          name = "config-template"
          projected {
            sources {
              config_map {
                name = "openclaw-config"
                items {
                  key  = "openclaw.json"
                  path = "openclaw.json"
                }
              }
            }

            dynamic "sources" {
              for_each = var.cron_jobs_count > 0 ? [1] : []
              content {
                config_map {
                  name = "cron-jobs"
                  items {
                    key  = "jobs.json"
                    path = "jobs.json"
                  }
                }
              }
            }
          }
        }

        volume {
          name = "rendered-config"
          empty_dir {}
        }

        volume {
          name = "workspace-template"
          config_map {
            name = "openclaw-workspace"
          }
        }
      }
    }
  }
}

# --- n8n Deployment ---

resource "kubernetes_deployment" "n8n" {
  metadata {
    name      = "n8n"
    namespace = var.namespace
    labels    = { app = "n8n" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "n8n" }
    }

    template {
      metadata {
        labels = { app = "n8n" }
      }

      spec {
        security_context {
          run_as_user = 1000
          fs_group    = 1000
        }

        container {
          name  = "n8n"
          image = "n8nio/n8n:${var.n8n_version}"

          port {
            container_port = 5678
          }

          env {
            name  = "N8N_HOST"
            value = var.n8n_host
          }

          env {
            name  = "N8N_PORT"
            value = "5678"
          }

          env {
            name  = "N8N_PROTOCOL"
            value = "https"
          }

          env {
            name  = "WEBHOOK_URL"
            value = "https://${var.n8n_host}/"
          }

          env {
            name = "N8N_ENCRYPTION_KEY"
            value_from {
              secret_key_ref {
                name = "openclaw-api-keys"
                key  = "N8N_ENCRYPTION_KEY"
              }
            }
          }

          volume_mount {
            name       = "n8n-data"
            mount_path = "/home/node/.n8n"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "3Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 5678
            }
            initial_delay_seconds = 20
            period_seconds        = 30
          }
        }

        volume {
          name = "n8n-data"
          persistent_volume_claim {
            claim_name = "n8n-data"
          }
        }
      }
    }
  }
}

# --- FCM Push Deployment ---

resource "kubernetes_deployment" "fcm_push" {
  count = var.enable_fcm ? 1 : 0

  metadata {
    name      = "fcm-push"
    namespace = var.namespace
    labels    = { app = "fcm-push" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "fcm-push" }
    }

    template {
      metadata {
        labels = { app = "fcm-push" }
      }

      spec {
        security_context {
          run_as_user = 1000
          fs_group    = 1000
        }

        container {
          name  = "fcm-push"
          image = "localhost/fcm-push:latest"
          image_pull_policy = "Never"

          port {
            container_port = 3100
          }

          command = ["node", "/app/index.js"]

          volume_mount {
            name       = "fcm-data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "firebase-sa"
            mount_path = "/data/firebase-sa.json"
            sub_path   = "firebase-sa.json"
            read_only  = true
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3100
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }
        }

        volume {
          name = "fcm-data"
          persistent_volume_claim {
            claim_name = "fcm-data"
          }
        }

        volume {
          name = "firebase-sa"
          secret {
            secret_name = "firebase-sa"
          }
        }
      }
    }
  }
}

# --- Services (NodePort) ---

resource "kubernetes_service" "openclaw" {
  metadata {
    name      = "openclaw"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = { app = "openclaw" }
    port {
      port        = 18789
      target_port = 18789
      node_port   = 30789
    }
  }
}

resource "kubernetes_service" "n8n" {
  metadata {
    name      = "n8n"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = { app = "n8n" }
    port {
      port        = 5678
      target_port = 5678
      node_port   = 30678
    }
  }
}

resource "kubernetes_service" "fcm_push" {
  count = var.enable_fcm ? 1 : 0

  metadata {
    name      = "fcm-push"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = { app = "fcm-push" }
    port {
      port        = 3100
      target_port = 3100
      node_port   = 30100
    }
  }
}
