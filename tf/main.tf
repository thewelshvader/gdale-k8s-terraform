terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.54.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "k8s-native" {
  name     = "rsg-${var.suffix}"
  location = var.location
}
resource "azurerm_network_security_group" "k8s-native" {
  name                = "nsg-${var.suffix}"
  location            = azurerm_resource_group.k8s-native.location
  resource_group_name = azurerm_resource_group.k8s-native.name
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_virtual_network" "k8s-native" {
  name                = "vnet-${var.suffix}"
  location            = azurerm_resource_group.k8s-native.location
  resource_group_name = azurerm_resource_group.k8s-native.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "k8s-native" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.k8s-native.name
  virtual_network_name = azurerm_virtual_network.k8s-native.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "k8s-native" {
  subnet_id                 = azurerm_subnet.k8s-native.id
  network_security_group_id = azurerm_network_security_group.k8s-native.id
}
resource "random_id" "vm_name_unique" {
  count = 4
  byte_length = 4
}
resource "azurerm_public_ip" "k8s-native" {
  count               = 4
  name                = "vm_public_ip-${element(random_id.vm_name_unique.*.hex, count.index)}"
  resource_group_name = azurerm_resource_group.k8s-native.name
  location            = azurerm_resource_group.k8s-native.location
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface" "k8s-native" {
  count               = var.vm_count
  name                = element(random_id.vm_name_unique.*.hex, count.index)
  location            = azurerm_resource_group.k8s-native.location
  resource_group_name = azurerm_resource_group.k8s-native.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.k8s-native.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.k8s-native.*.id, count.index)
  }
}
resource "azurerm_virtual_machine" "main" {
  count                 = var.vm_count
  name                  = "vm-${element(random_id.vm_name_unique.*.hex, count.index)}"
  location              = azurerm_resource_group.k8s-native.location
  resource_group_name   = azurerm_resource_group.k8s-native.name
  network_interface_ids = [element(azurerm_network_interface.k8s-native.*.id, count.index)]
  vm_size               = "Standard_B4ms"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "vm-${element(random_id.vm_name_unique.*.hex, count.index)}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm-${element(random_id.vm_name_unique.*.hex, count.index)}-osdisk"
    admin_username = "sysadmin"
    admin_password = ""
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "kubernetes"
  }
}