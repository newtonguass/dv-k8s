variable "worker_count" {
  default = 1
}

variable "username" {
  default  = "k8s"
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
  default = "Standard_B2s"
}