terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# --- Prometheus (agent mode) → remote write to Grafana Cloud ---

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = true
  version          = "27.5.0"

  values = [yamlencode({
    server = {
      global = {
        scrape_interval = "30s"
      }
      remoteWrite = [
        {
          url = var.grafana_cloud_prometheus_url
          basic_auth = {
            username = var.grafana_cloud_user
            password = var.grafana_cloud_api_key
          }
        }
      ]
      persistentVolume = {
        enabled = false
      }
      resources = {
        requests = { cpu = "50m", memory = "128Mi" }
        limits   = { cpu = "200m", memory = "256Mi" }
      }
      retention = "2h"
    }

    alertmanager = {
      enabled = false
    }

    kube-state-metrics = {
      resources = {
        requests = { cpu = "10m", memory = "32Mi" }
        limits   = { cpu = "50m", memory = "64Mi" }
      }
    }

    prometheus-node-exporter = {
      resources = {
        requests = { cpu = "10m", memory = "16Mi" }
        limits   = { cpu = "50m", memory = "32Mi" }
      }
    }

    prometheus-pushgateway = {
      enabled = false
    }
  })]
}

# --- Grafana Alloy (logs → Grafana Cloud Loki) ---

resource "helm_release" "alloy" {
  name             = "alloy"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "alloy"
  namespace        = "monitoring"
  create_namespace = true
  version          = "0.12.0"

  values = [yamlencode({
    alloy = {
      configMap = {
        create = true
        content = <<-EOT
          // Discover pods
          discovery.kubernetes "pods" {
            role = "pod"
          }

          // Relabel to extract metadata
          discovery.relabel "pods" {
            targets = discovery.kubernetes.pods.targets

            rule {
              source_labels = ["__meta_kubernetes_namespace"]
              target_label  = "namespace"
            }
            rule {
              source_labels = ["__meta_kubernetes_pod_name"]
              target_label  = "pod"
            }
            rule {
              source_labels = ["__meta_kubernetes_pod_container_name"]
              target_label  = "container"
            }
          }

          // Collect logs
          loki.source.kubernetes "pods" {
            targets    = discovery.relabel.pods.output
            forward_to = [loki.write.grafana_cloud.receiver]
          }

          // Push to Grafana Cloud Loki
          loki.write "grafana_cloud" {
            endpoint {
              url = "${var.grafana_cloud_loki_url}"
              basic_auth {
                username = "${var.grafana_cloud_user}"
                password = "${var.grafana_cloud_api_key}"
              }
            }
          }
        EOT
      }
    }

    resources = {
      requests = { cpu = "10m", memory = "32Mi" }
      limits   = { cpu = "100m", memory = "64Mi" }
    }
  })]
}
