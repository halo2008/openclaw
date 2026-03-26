variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "ssh_port" {
  type = number
}

variable "allowed_ssh_ips" {
  type = list(string)
}

variable "labels" {
  type = map(string)
}
