variable "nodecount" {
  default = 2
}

variable "username" {
  description = "administrator username"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "administrator password"
  type        = string
  sensitive   = true
}

variable "prefix" {
  default = "dv-k8s"
}

data "external" "getIP" {
  program = ["bash", "getIP.sh"]
}