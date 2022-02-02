terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}




resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "japan East"
}
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-sg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allowCurrentIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "${data.external.getIP.result.ip}/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "intranet" {
  name                 = "${var.prefix}-intranet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-publicIP-${count.index}"
  count               = var.worker_count+1
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic-${count.index}"
  count               = var.worker_count+1
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     = azurerm_subnet.intranet.id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.0.2.${count.index + 10}"
    public_ip_address_id          = azurerm_public_ip.main[count.index].id 
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  count                     = var.worker_count+1
  network_interface_id      = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "main" {
    count                 = var.worker_count+1
    name                  = "${var.prefix}-node-${count.index}"
    location              = azurerm_resource_group.main.location
    resource_group_name   = azurerm_resource_group.main.name
    network_interface_ids = [azurerm_network_interface.main[count.index].id]
    size                  = var.vm_size

    os_disk {
        name                 = "${var.prefix}-disk-${count.index}"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }


    source_image_reference {
      publisher = var.image.publisher
      offer     = var.image.offer
      sku       = var.image.sku
      version   = var.image.version
    }

    computer_name  = "${var.prefix}-node-${count.index}"
    admin_username = var.username
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.username
        public_key     = tls_private_key.main.public_key_openssh
    }
}