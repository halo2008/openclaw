terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# --- Default deny all ingress in openclaw namespace ---

resource "kubernetes_network_policy" "default_deny_ingress" {
  metadata {
    name      = "default-deny-ingress"
    namespace = var.namespace
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

# --- OpenClaw: allow ingress from NodePort (all sources) ---

resource "kubernetes_network_policy" "openclaw_ingress" {
  metadata {
    name      = "openclaw-allow-ingress"
    namespace = var.namespace
  }
  spec {
    pod_selector {
      match_labels = { app = "openclaw" }
    }
    policy_types = ["Ingress"]

    ingress {
      ports {
        port     = "18789"
        protocol = "TCP"
      }
    }
  }
}

# --- OpenClaw: allow all egress (LLM APIs, n8n webhooks, etc.) ---

resource "kubernetes_network_policy" "openclaw_egress" {
  metadata {
    name      = "openclaw-allow-egress"
    namespace = var.namespace
  }
  spec {
    pod_selector {
      match_labels = { app = "openclaw" }
    }
    policy_types = ["Egress"]

    egress {}
  }
}

# --- n8n: allow ingress from NodePort ---

resource "kubernetes_network_policy" "n8n_ingress" {
  metadata {
    name      = "n8n-allow-ingress"
    namespace = var.namespace
  }
  spec {
    pod_selector {
      match_labels = { app = "n8n" }
    }
    policy_types = ["Ingress"]

    ingress {
      ports {
        port     = "5678"
        protocol = "TCP"
      }
    }
  }
}

# --- n8n: allow all egress (webhook URLs, external APIs) ---

resource "kubernetes_network_policy" "n8n_egress" {
  metadata {
    name      = "n8n-allow-egress"
    namespace = var.namespace
  }
  spec {
    pod_selector {
      match_labels = { app = "n8n" }
    }
    policy_types = ["Egress"]

    egress {}
  }
}

# --- FCM Push: allow ingress from namespace pods + NodePort ---

resource "kubernetes_network_policy" "fcm_push_ingress" {
  count = var.enable_fcm ? 1 : 0

  metadata {
    name      = "fcm-push-allow-ingress"
    namespace = var.namespace
  }
  spec {
    pod_selector {
      match_labels = { app = "fcm-push" }
    }
    policy_types = ["Ingress"]

    ingress {
      ports {
        port     = "3100"
        protocol = "TCP"
      }
    }
  }
}

# --- FCM Push: allow egress to googleapis.com (FCM API) + DNS ---

resource "kubernetes_network_policy" "fcm_push_egress" {
  count = var.enable_fcm ? 1 : 0

  metadata {
    name      = "fcm-push-allow-egress"
    namespace = var.namespace
  }
  spec {
    pod_selector {
      match_labels = { app = "fcm-push" }
    }
    policy_types = ["Egress"]

    # DNS
    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }

    # HTTPS (googleapis.com, oauth2.googleapis.com, fcm.googleapis.com)
    egress {
      ports {
        port     = "443"
        protocol = "TCP"
      }
    }
  }
}
