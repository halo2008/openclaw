terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

resource "hcloud_server" "main" {
  name         = "${var.project}-${var.environment}"
  server_type  = var.server_type
  location     = var.location
  image        = "ubuntu-24.04"
  ssh_keys     = [var.ssh_key_id]
  labels       = var.labels
  firewall_ids = var.firewall_ids

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = var.network_id
  }

  user_data = templatefile("${path.module}/cloud-init.yml", {
    tunnel_token = var.tunnel_token
    ssh_port     = var.ssh_port
    ssh_user     = var.ssh_user
    ssh_pub_key  = var.ssh_pub_key
  })

  depends_on = [var.subnet_id]
}
