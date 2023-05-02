variable "suffix" {
 type = string
 default = "k8s-native"
 description = "Resource Group Name"
}
variable "location" {
 type = string
 default = "uksouth"
 description = "Azure Region"
}
variable "vm_count" {
 type = string
 default = "3"
 description = "Number of VMs to deploy"
}