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
}
resource "azurerm_virtual_network" "k8s-native" {
  name                = "vnet-${var.suffix}"
  location            = azurerm_resource_group.k8s-native.location
  resource_group_name = azurerm_resource_group.k8s-native.name
  address_space       = ["10.0.0.0/16"]
  subnet {
    name           = "snet-${var.suffix}"
    address_prefix = "10.0.1.0/24"
  }
}
resource "random_id" "vm_name_unique" {
  count = "${var.vm_count}"
  byte_length = 4
}

resource "azurerm_network_interface" "k8s-native" {
  count               = var.vm_count
  name                = element(random_id.vm_name_unique.*.hex, count.index)
  location            = azurerm_resource_group.k8s-native.location
  resource_group_name = azurerm_resource_group.k8s-native.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.k8s-native.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}