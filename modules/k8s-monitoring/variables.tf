variable "grafana_cloud_prometheus_url" {
  description = "Grafana Cloud Prometheus remote write URL"
  type        = string
}

variable "grafana_cloud_loki_url" {
  description = "Grafana Cloud Loki push URL"
  type        = string
}

variable "grafana_cloud_user" {
  description = "Grafana Cloud user/instance ID"
  type        = string
}

variable "grafana_cloud_api_key" {
  description = "Grafana Cloud API key"
  type        = string
  sensitive   = true
}
