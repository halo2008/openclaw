terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

# --- External Secrets Operator ---

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.12.1"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "resources.limits.memory"
    value = "128Mi"
  }
}

# --- GCP SA key for ESO auth ---

resource "kubernetes_secret" "gcp_sa_key" {
  metadata {
    name      = "gcp-sa-key"
    namespace = "external-secrets"
  }

  data = {
    "sa-key.json" = var.eso_sa_key_json
  }

  depends_on = [helm_release.external_secrets]
}

# --- ClusterSecretStore ---

resource "kubectl_manifest" "gcp_secret_store" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: gcp-secret-store
spec:
  provider:
    gcpsm:
      projectID: "${var.gcp_project_id}"
      auth:
        secretRef:
          secretAccessKeySecretRef:
            name: gcp-sa-key
            namespace: external-secrets
            key: sa-key.json
YAML

  depends_on = [
    helm_release.external_secrets,
    kubernetes_secret.gcp_sa_key,
  ]
}
