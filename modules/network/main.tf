terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

resource "hcloud_network" "vpc" {
  name     = "${var.project}-vpc-${var.environment}"
  ip_range = var.vpc_ip_range
  labels   = var.labels
}

resource "hcloud_network_subnet" "main" {
  network_id   = hcloud_network.vpc.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.subnet_ip_range
}
