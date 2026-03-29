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
    tunnel_token       = var.tunnel_token
    ssh_port           = var.ssh_port
    ssh_user           = var.ssh_user
    ssh_pub_key        = var.ssh_pub_key
    openclaw_version   = var.openclaw_version
    fcm_push_index_js  = file("${path.module}/../../services/fcm-push/index.js")
    sshd_config        = templatefile("${path.module}/templates/sshd-hardening.conf.tpl", { ssh_port = var.ssh_port })
    fail2ban_config    = templatefile("${path.module}/templates/fail2ban.conf.tpl", { ssh_port = var.ssh_port })
  })

  depends_on = [var.subnet_id]
}

# --- Fetch kubeconfig after provisioning ---

resource "null_resource" "fetch_kubeconfig" {
  triggers = {
    server_id = hcloud_server.main.id
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /opt/openclaw-ready ]; do sleep 5; done",
      "cat /etc/rancher/k3s/k3s.yaml"
    ]

    connection {
      type        = "ssh"
      host        = hcloud_server.main.ipv4_address
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      port        = var.ssh_port
      timeout     = "10m"
    }
  }

  provisioner "local-exec" {
    command = <<-EOT
      scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} -P ${var.ssh_port} \
        ${var.ssh_user}@${hcloud_server.main.ipv4_address}:/etc/rancher/k3s/k3s.yaml \
        ~/.kube/config-openclaw
      sed -i 's/127.0.0.1/${hcloud_server.main.ipv4_address}/g' ~/.kube/config-openclaw
    EOT
  }
}
