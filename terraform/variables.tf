variable "worker_count" {
  description = "enter the how many worker node you want"
  type = number
  validation {
    condition     = can(regex("^[0-9]+$", var.worker_count))
    error_message = "Only integer value is allowed."
  }
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