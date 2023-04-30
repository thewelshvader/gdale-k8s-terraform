terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.54.0"
    }
  }
}
resource "azurerm_resource_group" "k8s-native" {
  name     = var.rsg_name
  location = var.location
}