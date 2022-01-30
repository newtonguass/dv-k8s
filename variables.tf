variable "nodecount" {
  default = 2
}

variable "username" {
  description = "administrator username"
  type        = string
}

variable "prefix" {
  default = "dv-k8s"
}

data "external" "getIP" {
  program = ["bash", "getIP.sh"]
}