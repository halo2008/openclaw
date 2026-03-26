variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_ip_range" {
  type = string
}

variable "subnet_ip_range" {
  type = string
}

variable "labels" {
  type = map(string)
}
