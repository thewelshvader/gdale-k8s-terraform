variable "suffix" {
 type = string
 default = "k8s-native"
 description = "Resource Group Name"
}
variable "rsg_name" {
 type = string
 default = "gdale-${var.suffix}"
 description = "Resource Group Name"
}
variable "location" {
 type = string
 default = "uksouth"
 description = "Azure Region"
}