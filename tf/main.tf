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