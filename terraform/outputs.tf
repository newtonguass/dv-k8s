output "public_ip_address" {
  description = "the public ip of nodes"
  value       = "${azurerm_public_ip.main.*.ip_address}"
}

output "node_username" {
  description = "the node username you input"
  value       = var.username
}

output "tls_private_key" { 
    value     = tls_private_key.main.private_key_pem 
    sensitive = true
}

/*
The machine will be created with a new SSH public key. 
To get the corresponding private key, run terraform output -raw tls_private_key.
 Save the output to a file on the local machine and use it to log in to the virtual machine.
 */