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

variable "nodecount" {
  default = 2
}

data "external" "getIP" {
  program = ["bash", "getIP.sh"]
}

variable "prefix" {
  default = "dv-k8s"
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
  count               = var.nodecount
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic-${count.index}"
  count               = var.nodecount
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
  count                     = var.nodecount
  network_interface_id      = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_virtual_machine" "main" {
  count                 = var.nodecount
  name                  = "${var.prefix}-node-${count.index}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "k8snode"
    admin_username = "k8s"
    admin_password = "K8Spa$$wd"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

output "public_ip_address" {
  value = "${azurerm_public_ip.main.*.ip_address}"
}
