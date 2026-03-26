output "network_id" {
  value = hcloud_network.vpc.id
}

output "subnet_id" {
  value = hcloud_network_subnet.main.id
}
