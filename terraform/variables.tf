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

variable "image" {
  type = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
  })
  default = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
  
}

variable "vm_size" {
  default = "Standard_D2S_v3"
}