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
resource "azurerm_network_security_group" "example" {
  name                = "nsg-${var.suffix}"
  location            = azurerm_resource_group.k8s-native.location
  resource_group_name = azurerm_resource_group.k8s-native.name
}